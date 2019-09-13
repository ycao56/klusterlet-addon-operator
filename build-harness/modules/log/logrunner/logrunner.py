#!/usr/bin/env python3
# This script is used to run the travis logger
import sys
import traceback

from travislogger import is_travis_build
from travislogger.main import main

if __name__ == '__main__':
    if not is_travis_build():
        print('Travis environment not recognized; logger is being run locally')
        sys.exit(main(local=True))
    else:
        try:
            sys.exit(main(local=False))
        except Exception as e:
            # if we have an error, we do not want to mess up any build!
            print('*\n*\n*\n*\n*\n*')
            print('ERROR CAUGHT IN SCRIPT!')
            print('(If you see this, let CICD know. :) )')
            traceback.print_exc()
            print('*\n*\n*\n*\n*\n*')
