from dell import ctx
from dell.state import ctx_parameters as inputs
import json


directory = inputs.get('node_instance_id')
localpath = f'/tmp/{directory}/deployment_script_outputs.txt'
with open(localpath) as file:
    content = file.read()
ctx.instance.runtime_properties['upgrade_db_output'] = \
    json.loads(content.strip())
