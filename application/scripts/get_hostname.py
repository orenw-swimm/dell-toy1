from dell import ctx
from dell.state import ctx_parameters as inputs
import shutil


directory = inputs.get('node_instance_id')

localpath = f'/tmp/{directory}/vm_hostname.txt'
with open(localpath) as file:
    content = file.read()
ctx.instance.runtime_properties['hostname'] = \
    content.strip()

# Clean up temp file
dir_localpath = f'/tmp/{directory}'
try:
    shutil.rmtree(dir_localpath)
except Exception as removal_error:
    ctx.logger.error(
        f'{dir_localpath} temp files removal error: {removal_error}')
