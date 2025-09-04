from dell import ctx
from dell.exceptions import NonRecoverableError, RecoverableError
from dell.manager import get_rest_client
from dell.state import ctx_parameters as inputs


SMTP_SECRET_NAME = ''
SMTP_SECRET_CREATED = False

client = get_rest_client()
smtp_enable = inputs.get('smtp_enable')
smtp_password_secret_name = inputs.get('smtp_password_secret_name')


if not smtp_enable:
    ctx.logger.info('SMTP is disabled')
    empty_secret_name = f'xmpro-smtp-password-{ctx.deployment.id}'
    empty_secret_value = ' '
    client.secrets.create(empty_secret_name, empty_secret_value)
    ctx.logger.debug(
        f'Created an empty secret for SMTP compatibility: {empty_secret_name}')
    SMTP_SECRET_NAME = empty_secret_name
    SMTP_SECRET_CREATED = True
else:
    ctx.logger.info('SMTP is enabled')
    if not smtp_password_secret_name:
        raise NonRecoverableError(
            'SMTP is enabled but SMTP Password Secret Name was not provided.')
    try:
        smtp_password = client.secrets.get(str(smtp_password_secret_name)).value
    except Exception as e:
        raise NonRecoverableError(
            f'Could not retrieve value of the secret: {smtp_password_secret_name}\n'
            f'Error: {str(e)}\n'
            'Is the secret name correct and is it available?')
    SMTP_SECRET_NAME = smtp_password_secret_name

if not SMTP_SECRET_NAME:
    raise RecoverableError('Could not resolve SMTP Password Secret Name')

ctx.instance.runtime_properties['smtp_password_secret_name'] = SMTP_SECRET_NAME
ctx.instance.runtime_properties['smtp_password_secret_created'] = SMTP_SECRET_CREATED
