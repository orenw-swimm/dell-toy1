SHELL := /bin/bash
ROOT_PATH = ../..
ZIP_TARGET_PATH = ./XMPro
FOLDER_PATH = ./MFG
FOLDER = XMPro
VSPHERE_SUITE_ZIP = XMPro_Suite_for_vSphere
NE_SUITE_ZIP = XMPro_Suite_for_NativeEdge_Endpoint
VSPHERE_STREAM_ZIP = XMPro_Stream_Host_for_vSphere
NE_STREAM_ZIP = XMPro_Stream_Host_for_NativeEdge_Endpoint
EXCLUDE_PATTERNS="'tests/*' '*/tests/*' '$(FOLDER)/.test*' '$(FOLDER)/tox.ini' '$(FOLDER)/requirements.txt' '$(FOLDER)/Makefile' '$(FOLDER)/.gitignore'"
# This target triggers the Python script to generate yaml with common inputs
generate_common_inputs:
	python3 $(ROOT_PATH)/POCs/common_inputs_script/code/copy_common_inputs.py -c 'POCs/common_inputs_script/isv_configs/xmpro_stream_host_inputs_config.yaml'
	python3 $(ROOT_PATH)/POCs/common_inputs_script/code/copy_common_inputs.py -c 'POCs/common_inputs_script/isv_configs/xmpro_suite_inputs_config.yaml'

# This target create a .zip with a blueprint-template
zip_blueprint:
	cd $(ROOT_PATH)/$(FOLDER_PATH) && zip -r $(ZIP_TARGET_PATH)/$(NE_SUITE_ZIP).zip $(FOLDER) -x "$(FOLDER)/infrastructure/xmpro_suite/vsphere/*" \
	"$(FOLDER)/infrastructure/xmpro_stream_host/*" "$(FOLDER)/tests/*" "$(FOLDER)/*$(VSPHERE_SUITE_ZIP)*" "$(FOLDER)/*$(NE_STREAM_ZIP)*" \
	"$(FOLDER)/*$(VSPHERE_STREAM_ZIP)*" "$(EXCLUDE_PATTERNS)"
	cd $(ROOT_PATH)/$(FOLDER_PATH) && zip -r $(ZIP_TARGET_PATH)/$(VSPHERE_SUITE_ZIP).zip $(FOLDER) -x "$(FOLDER)/infrastructure/xmpro_suite/nativeedge_endpoint/*" \
	"$(FOLDER)/infrastructure/xmpro_stream_host/*" "$(FOLDER)/tests/*" "$(FOLDER)/*$(NE_SUITE_ZIP)*" "$(FOLDER)/*$(NE_STREAM_ZIP)*" \
	"$(FOLDER)/*$(VSPHERE_STREAM_ZIP)*" "$(EXCLUDE_PATTERNS)"
	cd $(ROOT_PATH)/$(FOLDER_PATH) && zip -r $(ZIP_TARGET_PATH)/$(NE_STREAM_ZIP).zip $(FOLDER) -x "$(FOLDER)/infrastructure/xmpro_stream_host/vsphere/*" \
	"$(FOLDER)/infrastructure/xmpro_suite/*" "$(FOLDER)/tests/*" "$(FOLDER)/*$(NE_SUITE_ZIP)*" "$(FOLDER)/*$(VSPHERE_SUITE_ZIP)*" \
	"$(FOLDER)/*$(VSPHERE_STREAM_ZIP)*" "$(EXCLUDE_PATTERNS)"
	cd $(ROOT_PATH)/$(FOLDER_PATH) && zip -r $(ZIP_TARGET_PATH)/$(VSPHERE_STREAM_ZIP).zip $(FOLDER) -x "$(FOLDER)/infrastructure/xmpro_stream_host/nativeedge_endpoint/*" \
	"$(FOLDER)/infrastructure/xmpro_suite/*" "$(FOLDER)/tests/*" "$(FOLDER)/*$(NE_SUITE_ZIP)*" "$(FOLDER)/*$(VSPHERE_SUITE_ZIP)*" \
	"$(FOLDER)/*$(NE_STREAM_ZIP)*" "$(EXCLUDE_PATTERNS)"

# This target is the default target and triggers 'generate_common_inputs' and 'zip_blueprint' targets
all: generate_common_inputs

# This target removes created .zip
clean:
	cd $(ROOT_PATH)/$(FOLDER_PATH) && rm -f $(ZIP_TARGET_PATH)/$(VSPHERE_SUITE_ZIP).zip
	cd $(ROOT_PATH)/$(FOLDER_PATH) && rm -f $(ZIP_TARGET_PATH)/$(NE_SUITE_ZIP).zip
	cd $(ROOT_PATH)/$(FOLDER_PATH) && rm -f $(ZIP_TARGET_PATH)/$(NE_STREAM_ZIP).zip
	cd $(ROOT_PATH)/$(FOLDER_PATH) && rm -f $(ZIP_TARGET_PATH)/$(VSPHERE_STREAM_ZIP).zip