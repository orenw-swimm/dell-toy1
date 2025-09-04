import json

from dell import ctx
from dell.exceptions import NonRecoverableError
from dell.manager import get_rest_client
from dell.state import ctx_parameters as inputs

client = get_rest_client()
base_url_secret_name = inputs.get('base_url_secret_name')
json_url_key = inputs.get('json_url_key')
company_admin_password_secret_name = \
    inputs.get('company_admin_password_secret_name')
site_admin_password_secret_name = \
    inputs.get('site_admin_password_secret_name')

try:
    base_url_secret = client.secrets.get(
        str(base_url_secret_name)).value
    company_admin_password_secret = client.secrets.get(
        str(company_admin_password_secret_name)).value
    site_admin_password_secret = client.secrets.get(
        str(site_admin_password_secret_name)).value

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

xmpro_secrets = {
    company_admin_password_secret_name: company_admin_password_secret,
    site_admin_password_secret_name: site_admin_password_secret
}

for secret_name, secret_value in xmpro_secrets.items():
    if secret_value == "":
        raise NonRecoverableError(
            f'Secret "{secret_name}" is empty.\n'
            'Is the secret name and format correct and is it available?')
    if any(char in ['`', '\'', '\\', '"', '$', '@'] for char in secret_value):
        raise NonRecoverableError(
            f'Secret "{secret_name}" contains illegal character.\n'
            'Password must not contain any of the following special '
            'characters: `\'\\"$@')
    if len(secret_value) < 8 or len(secret_value) > 50:
        raise NonRecoverableError(
            f'Secret "{secret_name}" does not meet length requirements.\n'
            'Password must be between 8 and 50 characters long.')

ctx.logger.info('Successfully validated XMPro Admins passwords from secrets.')
