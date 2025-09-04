entry point MFG/XMPro/XMPro_Suite_for_NativeEdge_Endpoint.yaml

# Solution Architecture
## Overview

descriiptio nshould come from the bluepritn description itself
MFG/XMPro/XMPro_Suite_for_NativeEdge_Endpoint.yaml:4

The components that are in use that from the graph are taken from the bluepritnt iself
MFG/XMPro/XMPro_Suite_for_NativeEdge_Endpoint.yaml:32-34

Those impored files have multiple items that form a component. In the future we might simplify this design for better docs generation in visibility by using a ServiceComposition patter like in MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/components/application_designer/blueprint.yaml:40 that represents another blueprint

## Architecture Diagram
is also taken from the bluepritn iself, where the major components represented by multiplenodes. The blueprint defines a graph and all the dependencies are placed there as relationships fomring the edges.

Types of automation used like ansible are based on the node belonging to a plugin MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/components/application_designer/blueprint.yaml:109

# Blueprint Structure
# Blueprint Diagram
this represnts the impored items dfined in the main yaml file 
MFG/XMPro/XMPro_Suite_for_NativeEdge_Endpoint.yaml:22-41

## Blueprint Directory Structure
is a listing of directories with short descrioption of what each of them defines as a paart of the bluepritn archive

# Prerequisites
## Sizing
this is from the vendors site, we should aither fetch that  autmatically (if possible) or agree on how to store sizing information in the blueprint.

## Operating System
this is based on the blueprint in use that deplopys a VM. Linux or Windows MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/components/application_designer/blueprint.yaml:46
In this case thios is a winfdows one and the image in uses is defined in MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/components/application_designer/blueprint.yaml:64
which is represented in MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/blueprint.yaml:12 - this defines the URL from which the image is fetched.
That url is defined in MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/inputs.yaml:55 and takes value form a secret

## Artifacts and Binaries
There are two kinds of artifacts and binaries:
1. the ones that are used to create a VM
2. the ones that are used to install the software on the VM

ad 1. See the Oeprating System note
That on is used with MFG/XMPro/infrastructure/xmpro_stream_host/nativeedge_endpoint/blueprint.yaml:37 to upload the image (for NativeEdge) or with MFG/XMPro/infrastructure/xmpro_suite/vsphere/components/data_stream_designer/blueprint.yaml:20 to define existing tamplate name in vSphere

ad 2. The binaries are used in download scripts and usually are mapped to inputs that are rtrieved from a secret
Example is at MFG/XMPro/application/mssql_server/inputs.yaml:15 whre the fine name is anchored and used in other palces to get the file.
artifacts are retrieved from a common URL location that is defined as a secret. The file name is concatenated to the URL (a base path) to fetch that the VM.
Sometimes the blueprtins will just use the file names fixed abd that would be in the script downloading the file.
For linux curl or wget or ansible role: MFG/XMPro/application/ansible/install_mssql_server.yaml:20

For wirndows we use ansible or powershell

## Secrets
these are all in the bluepritn that are used as get_secret. usually it is followed by another intrinsic function that selects the name of the secret to fetch
MFG/XMPro/application/application_designer/blueprint.yaml:26
The input that defines this secret name will be of type secret_key MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/components/application_designer/inputs.yaml:20

## Plugins
All plugins in use are found in imports section and start with plugin: MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/blueprint.yaml:2

# Inputs
Inputs are defined in the inputs section that might be in one file, or in the imported files (imports section)

# Install Workflow
It maps to all the nodes lifecycle operations that define a blueprint.
Once the bluepritn is defined (it is a grapth) the workflow will walk trough it executiing lifecycle operaitons defined under interfaces.
MFG/XMPro/application/blueprint.yaml:11 and MFG/XMPro/application/blueprint.yaml:22 define waht does that mean to create an starte that node (instacnce). The script dfines it.
If a node is from a plugin, the lifecycle operation is defined in that plugin. I do not thing we need to go that deep now, it is enough to understand what the node does and what does it mean to install it.
https://docs.cloudify.co/latest/working_with/workflows/built-in-workflows/#the-install-workflow

# Uninstall Workflow
It works the same as install, but in the reverse order and runs other lifecycle operations
https://docs.cloudify.co/latest/working_with/workflows/built-in-workflows/#the-uninstall-workflow

# Deployment Capabilities and Outputs
MFG/XMPro/application/outputs.yaml:1
defined in capabilities and output secrions
We rarely use the outputs section, most of those will be in capabilities, but their general purpose is the same. Capabilities are additionally evalueted on demand so 

# Interaction Diagram for Native Edge Endpoint Installation
This one is derrived form the execution graph.
The entieties  will be the Orchestrsator and extranl systems
For the nodes using the nativeedge-plugin MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/blueprint.yaml:6
and generic ones that deploy a VM MFG/XMPro/infrastructure/xmpro_suite/nativeedge_endpoint/components/application_designer/blueprint.yaml:40 there will be NativeeEdge Device as target. Similar will be with vSphere.

After the VM is create and the address of the VM fetched the nodes in application folder will be responsible for interacting with the hosted VM.

External repository server is where the arttifacts and binaries are stored.

# Monitoring and Debugging
This section is generic in a sence that monitoring and debuggin will always include the logs analysis, but the UI screenshots need to be provided per each solution.

