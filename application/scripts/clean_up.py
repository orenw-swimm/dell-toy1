from dell import ctx
from dell.state import ctx_parameters as inputs
import shutil


directory = inputs.get('node_instance_id')
localpath = f'/tmp/{directory}'
try:
    shutil.rmtree(localpath)
except Exception as removal_error:
    ctx.logger.error(
        f'{localpath} temp files removal error: {removal_error}')
