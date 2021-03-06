# R8X-API-scripts-4-policy-import-export

## Check Point R8X API scripts for policy import, export, modification

These are very rough scripts for handling policy and layer related operations for Check Point Software Technologies SmartManagement versions R8X utilizing the Management API.

## Repository Structure

Scripts will live in folders specific to their purpose with respect to the type of policy or layers they addrees, so specifically:

- Access Control Policy
  - List Access Control Layers
  - List Access Control Layers from Policy Packages
  - more pending
- HTTPS Inspection Policy
  - pending
- Threat Prevention Policy
  - List Threat Prevention Layers
  - List Threat Prevention Layers from Policy Packages
  - Threat Prevention Profiles (Export/Import)
  - Threat Prevention Rulebase (Export/Import)
  - Threat Prevention Rulebase Exceptions - Global Exceptions (Export/Import)
  - more pending

As these are explicitly different policy data sets.

## Environment and Version Assumptions/Requirements

Rough scripts have been built using an environment built on API version 1.7, so R81, but may work on earlier versions.  API version handling is currently not included in the rough scripts.

## Operation and API Authentication

The scripts are R8X Gaia bash scripts to operate at the expert CLI and will require either appropriate rights for the administrator using them or an ability to modify the scripts to change the authentication approach, currently defaulting to '-r true'.  Script variable 'MgmtCLI_Authentication' handles the API User Administrator's authentication.

## Management host web SSL port handling

Basic handling in the scripts accounts for the local SSL Web port such that it will adjust to enduser changes to the Management host's Gaia Web UI web SSL port automatically.

## Logging and Output

Detail controls for logging and output are not yet set, and aside from screen output, and the files for working operations and final results, log files are currently generated.  The current scripts create files for exported content, operations output and logging, show operation json output, and will utilize an import folder where import CSV files are expected.

Standard Folders added to each Policy type folder:
- _export.csv -- this folder is where usable export files are exported by the export operations
- _export.csv.FOR_REFERENCE_ONLY -- this folder is where "For Reference Only" files are generated by the export operations for reference
- _import.csv -- this folder is where the import operations will look for relevant files (as generated by export operation) to list for import
- _output -- this folder is for logging and results operations generated by import and delete operations that have a json output
- _output.json -- this folder is for show operation json files used for export operations or generated in list layer operations and available post partum

## MDSM - Multi-Domain Security Management Support

The scripts are currently not MDSM aware by nature, but script modification of the variable 'MgmtCLI_Authentication' will make MDSM operation possible, by adding correct and valid domain target.

## Caveats and Identified Limitations

The CAVEATS_AND_LIMITATIONS.md file will address caveats and identified limitations

## Future

Depending on the 4th dimension resourse availability (time), these scripts may be:

- integrated into the existing script template approach from <https://github.com/mybasementcloud/R8x-export-import-api-scripts>, thus expanding some of the extensive controls available for the script operation, API authentication, MDSM operation, logging, and other controls.
- Expanded to handle more key value sets for a specific script target output
- Edited to address updates in the API beyond version 1.7
- Edited to address support of back versions of the API, not earlier than R80.10
- Other policy elements from the existing technologies if available to the API, like NAT
- Provide delete operations to help clean-up some imported elements, since that will aid with testing
