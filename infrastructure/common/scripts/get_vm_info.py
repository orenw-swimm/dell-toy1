from dell import ctx
from dell.state import ctx_parameters as inputs
import shutil


vm_nativeedge_node_id = inputs['vm_nativeedge_node_id']
vm_ip_localpath = f'/tmp/{vm_nativeedge_node_id}/vm_ip.txt'
with open(vm_ip_localpath) as ip_file:
    content = ip_file.read()
ip_address = content.strip()

ctx.instance.runtime_properties['capabilities'] = {}
ctx.instance.runtime_properties['capabilities']['vm_host'] = \
    inputs.get('vm_host', '')
ctx.instance.runtime_properties['capabilities']['vm_public_ip'] = \
    str(ip_address)
ctx.instance.runtime_properties['capabilities']['vm_winrm_port'] = \
    inputs.get('vm_winrm_port', '')
ctx.instance.runtime_properties['capabilities']['vm_name'] = \
    inputs.get('vm_name', '')
ctx.instance.runtime_properties['capabilities']['vm_username'] = \
    inputs.get('vm_username', '')

# Clean up temp file
vm_ip_localpath = f'/tmp/{vm_nativeedge_node_id}'
try:
    shutil.rmtree(vm_ip_localpath)
except Exception as removal_error:
    ctx.logger.error(
        f'{vm_nativeedge_node_id} temp files removal error: {removal_error}')
