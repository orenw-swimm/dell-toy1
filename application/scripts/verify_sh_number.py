from dell import ctx
from dell.exceptions import NonRecoverableError
from dell.manager import get_rest_client
from dell.state import ctx_parameters as inputs


if __name__ == "__main__":
    #inputs
    client = get_rest_client()
    sh_instances_number = inputs.get('stream_host_instance_number_for_default')
    additional_instances_for_non_default_collection = inputs.get(
        "additional_instances_for_non_default_collection")

    #validate collections
    if (sh_instances_number <= 0 and
        not additional_instances_for_non_default_collection):
        error_msg = "Empty information about stream hosts to install.\n" \
                    "Check parameters...Number of default instances is 0" \
                    " or additional collection information are empty."
        raise NonRecoverableError(error_msg)


    for _ins in additional_instances_for_non_default_collection:
        gateways = []
        _col_id = _ins.get("collection_id")
        _col_secret = _ins.get("collection_secret")
        additional_instances_number = _ins.get("number_of_instances")
        if not _col_id or not _col_secret or not additional_instances_number:
            error_msg = "JSON with Instances for non-default collections" \
                        " are not correct. Check value of input...\n"
            raise NonRecoverableError(error_msg)
