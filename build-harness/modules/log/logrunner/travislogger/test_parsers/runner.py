import json
import glob
from os.path import basename, isfile
import pickle

from travislogger import get_travis_identifying_data, PICKLE_FILE
from travislogger.test_parsers.tap import parse_tap_suite
from travislogger.test_parsers.xml import parse_xml_suite
from travislogger.server_comm import ServerComm

ENDPOINT = '/tests'
sc = ServerComm()

SUPPORTED_FILE_TYPES = {
    'tap': parse_tap_suite,
    'xml': parse_xml_suite
}


def ingest_results_in_dir(directory, file_type=None):
    """
    Ingest all tests of the desired filetype within a directory, This does not perform a 
    recursive search for files, so they must all be located in the base directory.

    Args:
        directory (string): T\the directory to search in
        file_type (dict, optional): Defaults to None. a dictionary of the function to parse a file
            with keyed on the file extension

    Returns:
        tuple: two lists, the first is of the ingested suites and the second is the ingested test cases
    """

    ingested_suites = []
    ingested_cases = []
    if file_type is None:
        file_type = SUPPORTED_FILE_TYPES
    for ext, func in file_type.items():
        for f in glob.glob('{}/*.{}'.format(directory, ext)):
            suites, cases = func(f)
            ingested_suites.extend(suites)
            ingested_cases.extend(cases)
    return ingested_suites, ingested_cases


def ingest_supported_results_in_dir(args, local=True):
    """
    Ingest all supported filetypes in the directory. These filetypes are defined by the global
    variable SUPPORTED_FILE_TYPES

    Args:
        args (namespace): arguments passed from argparser
        local (bool, optional): Defaults to True. describes whether we are running this script locally
            (as opposed to in Travis)

    Returns:
        tuple: two lists, the first is of the ingested suites and the second is the ingested test cases
    """

    sc.local = local
    suites, cases = ingest_results_in_dir(args.directory)
    summary = summarize_suites(suites, cases, simulate=args.simulate)
    return handle_output(args, summary, suites, cases)


def ingest_xml_runner(args, local=True):
    """
    parse the arguments from main() to determine what path to follow for ingesting junit xml data
     see: https://github.com/windyroad/JUnit-Schema

    Args:
        args (namespace): arguments passed from argparse
        local (bool, optional): Defaults to True. defining whether the script thinks it is running locally

    Returns:
        tuple: two lists, the first is of the ingested suites and the second is the ingested test cases
    """
    sc.local = local
    if args.filename is not None:
        suites, cases = parse_xml_suite(args.filename)
        # raw_suites.append((args.filename, suite))
    elif args.directory is not None:
        suites, cases = ingest_results_in_dir(
            args.directory, {'xml': parse_xml_suite})

    summary = summarize_suites(suites, cases, simulate=args.simulate)
    return handle_output(args, summary, suites, cases)


def ingest_tap_runner(args, local=True):
    """
    parse the arguments from main() to determine what path to follow for ingesting tap data
     see: https://testanything.org/tap-specification.html

    Args:
        args (namespace): arguments passed from argparse
        local (bool, optional): Defaults to True. defining whether the script thinks it is running locally

    Returns:
        tuple: two lists, the first is of the ingested suites and the second is the ingested test cases
    """
    sc.local = local
    suites = []
    cases = []
    if args.filename is not None:
        suites, cases = parse_tap_suite(args.filename)
    elif args.directory is not None:
        suites, cases = ingest_results_in_dir(
            args.directory, {'tap': parse_tap_suite})
    else:
        suites, cases = parse_tap_suite()

    summary = summarize_suites(suites, cases, simulate=args.simulate)
    handle_output(args, summary, suites, cases)


def summarize_suites(suite_data, case_data, simulate=False):
    """
    create a summary for all suites ingested, add identifying data to each request data, and queue the
    requests to be sent

    Args:
        suite_data (list, dict): list of all suites that tests were ingested for
        case_data (list, dict): list of all cases that tests were ingested for
        simulate (bool, optional): Defaults to False. parameter describing whether only a simulation should occur. 
            This will print output to stdout instead of sending it to a server.

    Returns:
        dict: summary of all of the test suites run
    """
    identifying_data = get_travis_identifying_data()
    summary = {
        'noTestDataSent': 'false',
        'numPassed': 0,
        'numFailed': 0,
        'plannedTests': 0,
        'numSkipped': 0,
        'numSuites': 0
    }
    summary.update(identifying_data)
    for suite in suite_data:
        # all suite data is converted to strings when sending it, so make sure it is an integer
        summary['numPassed'] += int(suite['numPassed'])
        summary['numFailed'] += int(suite['numFailed'])
        if suite.get('plan', None) is not None:
            summary['plannedTests'] += int(suite['plan']['expectedTests'])
            if bool(suite['plan']['skip']):
                summary['numSkipped'] += 1
        else:
            summary['plannedTests'] += int(suite['numPassed']) + \
                int(suite['numFailed'])
        summary['numSuites'] += 1
        suite.update(identifying_data)
        if not simulate:
            sc.add_request(suite, '{}/{}'.format(ENDPOINT, 'suite'), 1)

    for case in case_data:
        case.update(identifying_data)
        if not simulate:
            sc.add_request(case, '{}/{}'.format(ENDPOINT, 'case'), 2)

    if not simulate:
        sc.add_request(summary, '{}/{}'.format(ENDPOINT, 'summary'), 0)
    return summary


def send_empty_test_summary(args):
    """
    Send a summary indicating that no tests were run. This is defined by the key `noTestDataSent`.

    Args:
        args (namespace): arguments passed from argparse
    """

    identifying_data = get_travis_identifying_data()
    summary = {
        'noTestDataSent': 'true',
        'message': 'No tests were attempted to be sent'
    }
    summary.update(identifying_data)

    if not args.simulate:
        sc.add_request(summary, '{}/{}'.format(ENDPOINT, 'summary'), 0)
        sc.send_requests()
    else:
        print('No tests registered to be sent. Make sure you create some tests!')


def handle_output(args, summary, suites, cases):
    """
    common function to handle the output of test cases when sent to the server.
    This function sends/prints the test cases as needed.

    Args:
        args (namespace): arguments passed from argparse
        summary (dict): summary of all test suites ingested
        suites (list): list of dictionaries of the test suites ingested
        cases (list): list of dictionaries of the test cases ingested
    """
    try:
        with open(PICKLE_FILE, 'rb') as f:
            pickle_data = pickle.load(f)
        if args.simulate:
            print('summary:\n{}\nsuites:\n{}\ncases:\n{}\n'.format(
                summary, suites, cases))
        elif pickle_data.get('tests_sent', False):
            print('tests have already been sent for this build run. \
                  please ensure that all tests are in the same directory \
                  and you use the command: \
                        logrunner.py tests -d <test-directory>')
        else:
            queued_requests = sc.send_requests()
            # If we tried to send requests, register tests as sent
            if queued_requests > 0:
                pickle_data['tests_sent'] = True
                with open(PICKLE_FILE, 'wb') as f:
                    pickle.dump(pickle_data, f)
    except FileNotFoundError:
        print('Test data not sent to server. Build not detected because {} does not exist.'.format(
            PICKLE_FILE))
        print('summary:\n{}\nsuites:\n{}\ncases:\n{}\n'.format(
            summary, suites, cases))
