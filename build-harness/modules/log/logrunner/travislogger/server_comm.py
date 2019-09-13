import json
import heapq

import requests

from travislogger import VERSION, get_env

# SERVER_ADDRESS = '9.42.40.45'
# SERVER_PORT = '30333'
LOCAL_ADDRESS = '127.0.0.1'
LOCAL_PORT = '3333'
if get_env('IN_DOCKER') is not None:
    # supported docker hosts are mac and windows.
    #   the address should be 'docker.for.mac.localhost'
    #   or 'docker.for.win.localhost'.
    LOCAL_ADDRESS = 'docker.for.{}.localhost'.format(
        get_env('DOCKER_HOST_OS', 'mac').lower())

OVERRIDE_PANIC = get_env('CICD_OVERRIDE_PANIC', None) is not None

HEADERS = {
    'user-agent': 'travis-logger/{}'.format(VERSION),
    'Content-Type': 'application/json'
}


class ServerComm(object):
    """
    Object containing logic to send data to the server. It allows for sending a set of requests in a specific priority
    as well as sending individual requests.
    """
    _flag_base = 'https://raw.github.ibm.com/ICP-DevOps/feature-flags/master'
    _flag_location = 'cicd-travis-logger/panic.flag'
    _token = 'token {}'.format(get_env('GITHUB_TOKEN'))
    _valid_panics = ['true', '0', 'yes', 'for now']

    def __init__(self, local=True):
        """
            local (bool, optional): Defaults to True. Specify whether the script is being running locally
        """
        self.local = local
        self.server = LOCAL_ADDRESS
        self.port = '3333'
        self.posts = []
        self.env_check = False
        self.supports_https = True
        self._disable_requests = False

    def _check_env(self):
        """
        Check environment variables for server/address to send data to. If either variable
        is not set, default to the local environment.
        """
        if self.env_check:
            return
        server = get_env('CICD_LOGGING_SERVER')
        port = get_env('CICD_HTTP_LOGGING_PORT')
        if not self.local:
            r = requests.get('{}/{}'.format(self._flag_base, self._flag_location),
                             headers={'Authorization': self._token, 'Accept': 'application/vnd.github.v3.raw'})
            if r.content.decode('utf-8').strip().lower() in self._valid_panics and not OVERRIDE_PANIC:
                self._disable_requests = True
                return
            if server is None or port is None:
                self.local = True
                self.server = LOCAL_ADDRESS
                self.port = LOCAL_PORT
                print(
                    'Could not find server/port in environment variables. Forcing local run.')
            else:
                self.server = server
                self.port = port
        self.env_check = True

    def add_request(self, data, endpoint='', priority=5):
        """
        Add a request for sending to the internal priority queue.

        Args:
            data (dict): data to be sent to the server
            endpoint (str, optional): Defaults to ''None''. The api endpoint registered for the data sending
            priority (int, optional): Defaults to 5. The priority to sort the event by, a lower number indicates
                a higher priority.
        """
        if not endpoint.startswith('/'):
            endpoint = '/' + endpoint
        heapq.heappush(self.posts, (priority, (json.dumps(data), endpoint)))

    def send_requests(self):
        """
        Send all queued requests in priority order

        Returns:
            int: number of requests sent
        """
        self._check_env()
        status = []
        requests_queued = len(self.posts)
        if self._disable_requests:
            msg = 'sending requests temporarily disabled \
({} would have been sent).\ncicd needs to remove the panic flag to resume sending data'.format(requests_queued)
            print(msg)
            return requests_queued
        print('sending {} requests'.format(requests_queued))
        while self.posts:
            _, (data, endpoint) = heapq.heappop(self.posts)
            data = self._format_dict(json.loads(data))
            success, message = self._send_single_post(data, endpoint)
            if not success or (success and message.status_code != 200):
                status.append(message)
            print('.', end='', flush=True)
        if not status:
            print('\nrequests successful')
        else:
            print('\n{} error(s) encountered:'.format(len(status)))
            for e in status:
                print(e)
        return requests_queued

    def send_single_post(self, data, endpoint):
        """
        Send a single post request to the server. This method double checks to see if the required server data
        is set as environment variables.

        Args:
            data (dict): data to be sent to the server
            endpoint (str, optional): Defaults to ''None''. The api endpoint registered for the data sending

        Returns:
            int: number of requests sent
        """
        self._check_env()

        if self._disable_requests:
            msg = 'sending requests temporarily disabled \
(1 would have been sent).\ncicd needs to remove the panic flag to resume sending data.'
            print(msg)
            return 1
        print('sending single request')
        success, message = self._send_single_post(data, endpoint)
        if not success or (success and message.status_code != 200):
            print('error encountered:\n{}'.format(message))
        else:
            print('request successful')
        return 1

    def _send_single_post(self, data, endpoint):
        """
        Send a single post request to the server.

        Note:
            This method should not be called before ensuring that the server and port data stored on the object
            are correct.

        Args:
            data (dict): data to be sent to the server
            endpoint (str, optional): Defaults to ''None''. The api endpoint registered for the data sending

        Returns:
            tuple: whether the request succeeded and the message to print
        """

        host = 'https://{}:{}{}'.format(self.server, self.port, endpoint)
        if self.local:
            print(host)
            print(data)
        success = True
        if False and self.supports_https:
            # https connections not currently supported, so this block is disabled.
            try:
                r = requests.post(host, json=data, headers=HEADERS, timeout=2)
            except (requests.exceptions.SSLError, requests.exceptions.ConnectionError):
                try:
                    self.supports_https = False
                    host = 'http://{}:{}{}'.format(self.server,
                                                   self.port, endpoint)
                    r = requests.post(
                        host, json=data, headers=HEADERS, timeout=2)
                except requests.exceptions.ConnectionError as e:
                    success = False
                    r = e
        else:
            try:
                host = 'http://{}:{}{}'.format(self.server,
                                               self.port, endpoint)
                r = requests.post(host, json=data, headers=HEADERS, timeout=2)
            except (requests.exceptions.ConnectionError, requests.exceptions.ReadTimeout) as e:
                success = False
                r = e
        return success, r

    def _format_dict(self, d):
        """
        Recursively format a dict to ensure that all values are strings.

        Args:
            d (dict): Dictionary to convert all values for

        Returns:
            dict: the converted dictionary
        """

        if isinstance(d, str):
            return d
        for k, v in d.items():
            if isinstance(v, dict):
                self._format_dict(v)
            elif isinstance(v, list):
                for _, v2 in enumerate(v):
                    self._format_dict(v2)
            else:
                # ensure everything is a string
                d[k] = str(v)
        return d
