from itertools import count
from junitparser import JUnitXml, TestCase, TestSuite, Attr, Error, Skipped


class CustomSuite(TestSuite):
    """
    Customization of the TestSuite exposing package attribute
    """
    _tag = 'CustomSuite'
    package = Attr()


class CustomTestCase(TestCase):
    """
    Customization of TestCase exposing the assertions attribute
    """
    _tag = 'CustomTestCase'
    assertions = Attr()


def parse_xml_suite(input_filename):
    """
    parse an xml suite as defined by a single xml file

    Args:
        input_filename (str): file path to the test suite to parse

    Returns:
        tuple: two lists, the first is of the ingested suites and the second is the ingested test cases
    """
    suites = []
    all_cases = []
    xml = JUnitXml.fromfile(input_filename)
    for testsuite in xml:
        testsuite = CustomSuite.fromelem(testsuite)
        suite = {
            'numSkipped': 0,
            'numPassed': 0,
            'numFailed': 0,
            'expectedTests': 0,
            'testSuite': '{}'.format(testsuite.package),
            'fileName': input_filename
        }
        cases = []
        for i, testcase in zip(count(start=1, step=1), testsuite):
            testcase = CustomTestCase.fromelem(testcase)
            c = add_test_case(suite, testcase, i)
            cases.append(c)
        suites.append(suite)
        all_cases.extend(cases)
    return suites, all_cases


def add_test_case(suite, testcase, test_number):
    """
    add a test case to a test suite and return the test case parsed

    Side Effects:
        updates suite with the result of this test case

    Args:
        suite (dict): parsed test suite to update with results of this test case
        testcase (TestCase): raw test case to pull out information from
        test_number (int): number specifying which test case this is in the suite

    Returns:
        dict: the information of the test case parsed
    """
    # todo figure out how to determine the result of the test.
    case = {
        'testNumber': test_number,
        'testPassed': True,
        'testSkipped': False,
        'testError': False,
        'description': testcase.name,
        'assertions': testcase.assertions,
        'testTime': testcase.time,
        'testSuite': suite['testSuite'],
        'fileName': suite['fileName']
    }
    if testcase.result is not None:
        case['testPassed'] = False
        case['testResultMessage'] = testcase.result.message
        if isinstance(testcase.result, Skipped):
            case['testSkipped'] = True
        elif isinstance(testcase.result, Error):
            case['testError'] = True
    if case['testPassed']:
        suite['numPassed'] += 1
    elif case['testSkipped']:
        suite['numSkipped'] += 1
    else:
        suite['numFailed'] += 1
    suite['expectedTests'] += 1
    return case
