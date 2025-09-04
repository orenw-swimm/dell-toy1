import json

from dell import ctx
from dell.exceptions import NonRecoverableError
from dell.manager import get_rest_client
from dell.state import ctx_parameters as inputs

client = get_rest_client()
base_url_secret_name = inputs.get('base_url_secret_name')
json_url_key = inputs.get('json_url_key')

try:
    base_url_secret = client.secrets.get(
        str(base_url_secret_name)).value
    if isinstance(base_url_secret, str):
        base_url_secret = json.loads(base_url_secret)
    base_url = base_url_secret.get(json_url_key)
except Exception as e:
    raise NonRecoverableError(
        'Could not retrieve the value of secret. '
        f'Error: {str(e)}\n'
        'Is the secret name and format correct and is it available?')

if base_url == "":
    raise NonRecoverableError(
        f'{json_url_key} of secret {base_url_secret_name} is empty.')

if not base_url.endswith('/'):
    base_url = '{0}/'.format(base_url)

ctx.instance.runtime_properties['installer_url'] = base_url
ctx.logger.info('Prepared links to download files')

ctx.logger.info('Successfully validated secrets.')
