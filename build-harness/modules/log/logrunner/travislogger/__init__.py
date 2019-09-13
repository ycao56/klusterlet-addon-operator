import os as _os
VERSION = '0.3'
PICKLE_FILE = './state/logger.pickle'

if not _os.path.exists('./state'):
    _os.makedirs('./state')


def get_env(var=None, default=None):
    """
    Helper to get environment variables without erroring
        var (str, optional): Defaults to None. variable to get from the environment
        default (str, optional): Defaults to None. default to get if variable does not exist

    Returns:
        [various]: the value of the environment variable requested, None if it is not set,
            of a dictionary of all environment variables if none are requested
    """

    if var is not None:
        return _os.environ.get(var, default)
    return _os.environ


def get_travis_identifying_data():
    """
    Helper to get information that identifies a specific Travis build

    Returns:
        dict: the identifying information for the current build run
    """

    data = {
        'component': get_env('TRAVIS_REPO_SLUG'),
        'branch': get_env('TRAVIS_BRANCH'),
        'pullRequest': get_env('TRAVIS_PULL_REQUEST'),
        'pullRequestBranch': get_env('TRAVIS_PULL_REQUEST_BRANCH'),
        'pullRequestSource': get_env('TRAVIS_PULL_REQUEST_SLUG'),
        'buildNum': get_env('TRAVIS_BUILD_NUMBER'),
        'jobNum': get_env('TRAVIS_JOB_NUMBER'),
    }
    return data


def is_travis_build():
    """
    Helper to determine if we are currently in a travis build as identified by having
    the TRAVIS environment variable set

    Returns:
        bool: True iff the 'TRAVIS' variable is set
    """

    if get_env('TRAVIS') is None:
        return False
    for _, v in get_travis_identifying_data().items():
        if v is None:
            return False
    return True
