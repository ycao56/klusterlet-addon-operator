# todo POST /build {component, branch, build #, job #, time, build time, success, url (constructed from https://travis.ibm.com/TRAVIS_REPO_SLUG/jobs/TRAVIS_JOB_ID)}
# TRAVIS_TEST_RESULT
import os
import pickle
import datetime

from travislogger import get_env, get_travis_identifying_data, PICKLE_FILE
from travislogger.server_comm import ServerComm
from travislogger.test_parsers.runner import send_empty_test_summary

ENDPOINT = '/builds'
sc = ServerComm()


def datetime_str(d):
    """
    function to get the datetime in a standard format

    Args:
        d (datetime): the datetime object to format

    Returns:
        str: the formatted datetime string
    """

    return '{}.{}'.format(d.strftime("%B %d %Y, %H:%M:%S"), d.strftime("%f")[:3])


def start_build(args, local=True):
    """
    Get the information from Travis at the beginning of a build and send it to the logging server

    Args:
        args (namespace): arguments passed from argparse
        local (bool, optional): Defaults to True. defining whether the script thinks it is running locally
    """

    sc.local = local
    start_time = datetime.datetime.now()
    data = get_travis_identifying_data()
    data.update({
        'commitSha': get_env('TRAVIS_COMMIT'),
        'commitMsg': get_env('TRAVIS_COMMIT_MESSAGE'),
        'startTime': datetime_str(start_time),
        'eventType': 'start',
        'duration': '-1',
        'endTime': '-1',
        'url': 'https://travis.ibm.com/{}/jobs/{}'.format(get_env('TRAVIS_REPO_SLUG'), get_env('TRAVIS_JOB_ID'))
    })

    if not args.simulate:
        sc.send_single_post(data, ENDPOINT)
    else:
        print(data)

    data["datetime"] = start_time

    with open(PICKLE_FILE, 'wb') as f:
        pickle.dump(data, f)


def end_build(args, local=True):
    """
    Get the information from Travis at the end of a build and send it to the logging server

    Args:
        args (namespace): arguments passed from argparse
        local (bool, optional): Defaults to True. defining whether the script thinks it is running locally
    """

    sc.local = local
    end_time = datetime.datetime.now()
    with open(PICKLE_FILE, 'rb') as f:
        pickle_data = pickle.load(f)
    if pickle_data.get('datetime') is None:
        duration = '-1'
    else:
        duration = (end_time - pickle_data.get('datetime')).total_seconds()
    data = get_travis_identifying_data()
    data.update({
        'endTime': datetime_str(end_time),
        'duration': duration,
        'success': args.success,
        'eventType': 'end'
    })
    if not args.simulate:
        sc.send_single_post(data, ENDPOINT)
    else:
        print(data)

    if not pickle_data.get('tests_sent', False):
        send_empty_test_summary(args)
