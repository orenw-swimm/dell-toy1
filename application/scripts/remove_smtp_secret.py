from dell import ctx
from dell.manager import get_rest_client
from dell.state import ctx_parameters as inputs


client = get_rest_client()
smtp_password_secret_created = inputs.get('smtp_password_secret_created')
smtp_password_secret_name = inputs.get('smtp_password_secret_name')


if smtp_password_secret_created:
    try:
        ctx.logger.info('Removing SMTP Password secret')
        client.secrets.delete(smtp_password_secret_name)
    except Exception:
        ctx.logger.error(
            f'Could not delete the secret: {smtp_password_secret_name}')
