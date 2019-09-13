from os.path import isfile
import re

from tap import parser, line


p = parser.Parser()
BEGINNING_TEXT_TO_REMOVE = re.compile(r'^\W*')


def parse_tap_suite(input_file=None):
    """
    ingest a single TAP file from stdin or a file path

    Args:
        input_file (str, optional): Defaults to None. the path to the tap file to parse. If not present
            of if file does not exist, the tap output will be read from stdin

    Returns:
        tuple: two lists, the first is of the ingested suites and the second is the ingested test cases
    """

    suite = {
        'numSkipped': 0,
        'numPassed': 0,
        'numFailed': 0,
        'fileName': input_file,
        'failedTests': []
    }
    if input_file is None or not isfile(input_file):
        suite.update({
            'testSuite': 'stdin'
        })
        tap_p = p.parse_stdin()
    else:
        suite.update({
            'testSuite': '{}'.format(input_file)
        })
        tap_p = p.parse_file(input_file)
    return get_tap_suite(tap_p, suite)


def get_tap_suite(input_iterable, suite):
    """
    pull out the test summary and cases from a parsed TAP suite

    Args:
        input_iterable (iterable): generator for the tap test data

    Returns:
        tuple: two lists, the first is of the ingested suites and the second is the ingested test cases
    """

    cases = []
    for l in input_iterable:
        if l.category == 'test':
            cases.append(add_test_case(suite, l))
        elif l.category == 'diagnostic':
            # There can be more than one diagnostic. These are messages that are not tied to a specific test
            # and we can probably not send these if they exist.
            diagnostic = suite.get('diagnostics', [])
            diagnostic.append(l.text)
            suite['diagnostics'] = diagnostic
        elif l.category == 'plan':
            # There should only be one plan. If there are more, only save the first
            plan = {
                'expectedTests': l.expected_tests,
                'skip': l.skip
            }
            add_value_to_suite(suite, 'plan', plan)
        elif l.category == 'version':
            # There should only be one version. If there are more, only save the first!
            add_value_to_suite(suite, 'version', l.version)
        elif l.category == 'bail':
            bail = l.reason
            suite['testError'] = suite.get('bail', []).append(bail)

    return [suite], cases


def add_value_to_suite(test_suite, key, value):
    """
    add a value to the test suite only if it does not already exist

    Side Effects:
        might add a key, value pair to test_suite

    Args:
        test_suite (dict): parsed test suite to add this value to
        key (str): key to add the value at
        value (str, dict): value to add to the suite
    """

    if test_suite.get(key, None) is None:
        test_suite[key] = value
    else:
        print('Only one value of \'{}\' is supported. skipping declaration:\n{}'.format(
            key, value))


def add_test_case(suite, test_case):
    """
    add a test case to a test suite and return the test case parsed

    Side Effects:
        updates suite with the result of this test case

    Args:
        suite (dict): parsed test suite to update with results of this test case
        test_case (tap.line): the tappy test case line parsed

    Returns:
        dict: the information of the test case parsed
    """

    if test_case.ok:
        if test_case.directive.skip:
            suite['numSkipped'] += 1
        else:
            suite['numPassed'] += 1
    else:
        suite['numFailed'] += 1
        suite['failedTests'].append(
            {'testNumber': test_case.number, 'description': test_case.description})
    return {
        'testNumber': test_case.number,
        'testPassed': test_case.ok,
        'notImplemented': test_case.todo,
        'description': re.sub(BEGINNING_TEXT_TO_REMOVE, '', test_case.description),
        'comment': test_case.directive.reason,
        'testSkipped': test_case.directive.skip,
        'testSuite': suite['testSuite'],
        'fileName': suite['fileName'],
    }
