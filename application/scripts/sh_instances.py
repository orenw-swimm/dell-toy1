from dell import ctx
from dell.exceptions import NonRecoverableError
from dell.manager import get_rest_client
from dell.state import ctx_parameters as inputs


if __name__ == "__main__":
    #inputs
    client = get_rest_client()
    sh_instances_number= inputs.get('stream_host_instance_number_for_default')
    machine_name = inputs.get('machine_name')
    server_url = inputs.get('server_url')
    encryption_key = inputs.get('encryption_key')
    default_gateway_collection_id = inputs.get('default_gateway_collection_id')
    default_gateway_collection_secret = inputs.get(
        'default_gateway_collection_secret')
    additional_instances_for_non_default_collection = inputs.get(
        "additional_instances_for_non_default_collection")
    #additional parameters
    collections = []
    services_list = []
    counter = 1
    sh_name_format = "{0}_SH{1}"

    #for default collection
    gateways_default = []
    for i in range(0, int(sh_instances_number)):
        _name = sh_name_format.format(machine_name, "{:03d}".format(counter))
        services_list.append(_name)
        gateways_default.append(
            {
                "folderName": _name,
                "deviceName": _name,
                "rank": 0
            }
        )
        counter += 1
    collections.append(
        {
            "id": default_gateway_collection_id,
            "secret": default_gateway_collection_secret,
            "gateways": gateways_default
        }
    )
    # additional collections
    for _ins in additional_instances_for_non_default_collection:
        gateways = []
        _col_id = _ins.get("collection_id")
        _col_secret = _ins.get("collection_secret")
        additional_instances_number = _ins.get("number_of_instances")
        if not _col_id or not _col_secret or not additional_instances_number:
            error_msg = "JSON with Instances for non-default collections" \
                        " are not correct. Check value of input...\n"
            raise NonRecoverableError(error_msg)
        for i in range(0, int(additional_instances_number)):
            _name = sh_name_format.format(
                machine_name, "{:03d}".format(counter))
            services_list.append(_name)
            gateways.append(
                {
                    "folderName": _name,
                    "deviceName": _name,
                    "rank": 0
                }
            )
            counter += 1
        collections.append(
            {
                "id": _col_id,
                "secret": _col_secret,
                "gateways": gateways
            }
        )
    #validate collections
    if not collections:
        error_msg = "Empty information about stream hosts to install.\n" \
                    "Check parameters...Number of default instances is 0" \
                    " or additional collection information are empty."
        raise NonRecoverableError(error_msg)

    # save runtime properties
    ctx.instance.runtime_properties['stream_host_services_information'] = {
        "serverUrl": server_url,
        "encryptionKey": encryption_key,
        "collections": collections
    }
    ctx.instance.runtime_properties['sh_services'] = services_list
