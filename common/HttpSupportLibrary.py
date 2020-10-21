import requests
from os import getenv


def build_authz_headers():
    return {'Authorization': "Bearer %s" % getenv('BEARER_TOKEN')}


class HttpSupportLibrary:
    """An helper library for the HTTP calls"""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def se_create_dir_if_missing(self, url):
        """TBD"""

        headers = build_authz_headers()
        head = requests.head(url, headers=headers)

        if head.status_code == requests.codes.ok:
            # We assume that it's a dir, if exists
            return

        if head.status_code == requests.codes.not_found:
            mkcol = requests.request('MKCOL', url, headers=headers)
            mkcol.raise_for_status()
        else:
            head.raise_for_status()
