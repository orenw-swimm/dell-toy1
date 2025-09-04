from dell.state import ctx_parameters as inputs
from dell import ctx

EXCLUDED_INPUTS = ['ctx', 'script_path']


def main():
    for name, value in inputs.items():
        if name not in EXCLUDED_INPUTS:
            ctx.logger.debug("Setting runtime_property %s to %s" % (name, value))
            ctx.instance.runtime_properties[name] = value


if __name__ == "__main__":
    main()