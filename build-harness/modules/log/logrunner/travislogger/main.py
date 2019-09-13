import argparse
import os
import sys


from travislogger import VERSION
from travislogger.builds import start_build, end_build
from travislogger.test_parsers.runner import ingest_tap_runner, ingest_xml_runner, ingest_supported_results_in_dir


def main(local=True, argv=sys.argv, stream=sys.stderr):
    """
    main runner for this script. It will parse the command line arguments and pass them to the

    proper function.
        local (bool, optional): Defaults to True. [description]
        argv (list, optional): Defaults to sys.argv. list of parameters to pass
        stream (File object, optional): Defaults to sys.stderr. stream to report errors to. Not used here.

    Returns:
        int: the return code for the parser. 
    """

    parser, args = parse_args(argv)
    if len(argv) > 1:
        args.func(args, local=local)
    else:
        parser.print_help()
        return 1
    return 0


def parse_args(argv):
    """
    parse the known arguments passed in to this function in order to perform
    the desired action

    Args:
        argv (list): arguments passed from the command line

    Returns:
        tuple: the parser generated and arguments parsed
    """

    # Specify general information for the parser
    description = ''
    epilog = ''
    parser = argparse.ArgumentParser(description=description, epilog=epilog)
    parser.add_argument('-v', '--version', action='version',
                        version='%(prog)s {}'.format(VERSION))

    # add all of the subparsers
    subparser = parser.add_subparsers()
    for func in [
        register_begin_subcommand,
        register_end_subcommand,
        send_tap_tests_subcommand,
        send_xml_tests_subcommand,
        send_all_tests_subcommand
    ]:
        func(subparser)
    # parse the arguments and call the related function
    # ignore the first argument as that is the name of the function
    for _, sub in subparser.choices.items():
        sub.add_argument('-s',
                         '--simulate',
                         help='simulate the output that would be sent',
                         action='store_true')
    args = parser.parse_args(argv[1:])

    return parser, args


def register_begin_subcommand(subparser):
    """
    create a subcommand to register the beginning of the build

    Args:
        subparser (argparse._SubParsersAction): The action used to create subparsers
    """
    parser = subparser.add_parser('begin',
                                  help='register the beginning of a build')
    parser.set_defaults(func=start_build)


def register_end_subcommand(subparser):
    """
    create a subcommand to register the end of the build

    Args:
        subparser (argparse._SubParsersAction): The action used to create subparsers
    """
    parser = subparser.add_parser('end',
                                  help='register the completion of a build')
    build_result = parser.add_mutually_exclusive_group()
    build_result.add_argument('--success',
                              help='mark the build as successfully completed',
                              dest='success',
                              action='store_true')
    build_result.add_argument('--fail',
                              help='mark the build as UNsuccessfully completed',
                              dest='success',
                              action='store_false')
    parser.set_defaults(func=end_build)


def send_tap_tests_subcommand(subparser):
    """
    create a subcommand to send tap-formatted test results

    Args:
        subparser (argparse._SubParsersAction): The action used to create subparsers
    """
    parser = subparser.add_parser('tap',
                                  help='import a test result in TAP format')
    input_method = parser.add_mutually_exclusive_group()
    input_method.add_argument('-f',
                              '--filename',
                              help='the path to the file that you want to parse',
                              default=None)
    input_method.add_argument('-d',
                              '--directory',
                              help='the directory containing the .tap files to parse',
                              default=None)
    parser.set_defaults(func=ingest_tap_runner)


def send_xml_tests_subcommand(subparser):
    """
    create a subcommand to send xml-formatted test results

    Args:
        subparser (argparse._SubParsersAction): The action used to create subparsers
    """
    parser = subparser.add_parser('xml',
                                  help='import test in junit xml format')
    input_method = parser.add_mutually_exclusive_group(required=True)
    input_method.add_argument('-f',
                              '--filename',
                              help='the path to the file that you want to parse',
                              default=None)
    input_method.add_argument('-d',
                              '--directory',
                              help='the directory containing the .xml files to parse',
                              default=None)
    parser.set_defaults(func=ingest_xml_runner)


def send_all_tests_subcommand(subparser):
    """
    create a subcommand to send all supported test results

    Args:
        subparser (argparse._SubParsersAction): The action used to create subparsers
    """
    parser = subparser.add_parser('tests',
                                  help='import all tests in supported formats (junit xml, tap)')
    parser.add_argument('-d',
                        '--directory',
                        required=True,
                        help='the directory containing the .tap files to parse',
                        default=None)
    parser.set_defaults(func=ingest_supported_results_in_dir)
