# R8X-API-scripts-4-policy-import-export

## Check Point R8X API scripts for policy import, export, modification

### HTTPS Inspection policy and layer related scripts

These are very rough scripts for handling policy and layer related operations for Check Point Software Technologies SmartManagement versions R8X utilizing the Management API.

This folder handles the HTTPS Inspection policy and layer related scripts

## Caveats and Identified Limitations

Like all software there are CAVEATS and LIMITATIONS association with implementation and operation.

### CAVEATS list

1. There no stipulations that these scripts are complete or eternal, and may be easily superceded by changes in the API by later versions or changes in the underlying bash environment and Gaia Linux OS
2. These scripts are utilitarian examples, but for some applications actual effort may be required for both operation as well as potential additional development effort.
3. The scripts are tested to a limited extent but only in the context of their intended purpose, actual implementation version, and potential target environment.
4. The Check Point Management API is not complete, so all implementation is subject to the limitations of the implementation available and GA.  EA (Early Availability) operation suitability is possible, but not stipulated.
5. Older API versions than the implementation level(s) tested [currently API version 1.7] may not function or have more limitations than documented and require adjustments to either the scripts or the output to work
6. Users of these scripts should be capable of operating in the Gaia OS bash [expert] commandline, and no stipulations of function in just Gaia OS clish environment are made.

### LIMITATIONS - General

- These scripts DO NOT address the objects utilized in policy or layers and must exist or have a valid reference by name available when the export output is to be imported.  Non-existant items may cause the complete import operation to fail.
- Updatable Objects must be utilized at least once in the Management host / MDSM Domain to ensure they are available for the import operation
- Support for MDSM operation requires user adjustment of scripts
- Support for alternative authentication from "-r true" for local API host administrator requires user adjustment of scripts
- Import scripts to go with the export scripts.  Current approach means the user needs to execute a mgmg_cli command specific to the policy or layer export with the --batch option with the filename of the export CSV file to execute the import operation.
- For most scripts the export data, may require adjustment to handle different target management hosts or MDSM Domains.  A failure on import may invalidate the entire import operation.  Use of --format json option combines with details-level full on the import operation should provide details about the issues encountered.

### LIMITATIONS - HTTPS Inspection Policy

- Need to actually bang out a script for this