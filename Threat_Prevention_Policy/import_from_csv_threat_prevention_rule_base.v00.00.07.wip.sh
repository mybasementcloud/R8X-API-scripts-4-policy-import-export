#!/bin/bash
#
# (C) 2016-2021 Eric James Beasley, @mybasementcloud, https://github.com/mybasementcloud/R8X-API-scripts-4-policy-import-export
#
# ALL SCRIPTS ARE PROVIDED AS IS WITHOUT EXPRESS OR IMPLIED WARRANTY OF FUNCTION OR POTENTIAL FOR 
# DAMAGE Or ABUSE.  AUTHOR DOES NOT ACCEPT ANY RESPONSIBILITY FOR THE USE OF THESE SCRIPTS OR THE 
# RESULTS OF USING THESE SCRIPTS.  USING THESE SCRIPTS STIPULATES A CLEAR UNDERSTANDING OF RESPECTIVE
# TECHNOLOGIES AND UNDERLYING PROGRAMMING CONCEPTS AND STRUCTURES AND IMPLIES CORRECT IMPLEMENTATION
# OF RESPECTIVE BASELINE TECHNOLOGIES FOR PLATFORM UTILIZING THE SCRIPTS.  THIRD PARTY LIMITATIONS
# APPLY WITHIN THE SPECIFICS THEIR RESPECTIVE UTILIZATION AGREEMENTS AND LICENSES.  AUTHOR DOES NOT
# AUTHORIZE RESALE, LEASE, OR CHARGE FOR UTILIZATION OF THESE SCRIPTS BY ANY THIRD PARTY.
#
# SCRIPT Rough Example for importing threat prevention rule base exported to CSV with the export script
#
#

ScriptVersion=00.00.07
ScriptRevision=000
ScriptDate=2021-06-10
TemplateVersion=@NA
APISubscriptsLevel=@NA
APISubscriptsVersion=@NA
APISubscriptsRevision=@NA

#

# -------------------------------------------------------------------------------------------------
# Announce what we are starting here...
# -------------------------------------------------------------------------------------------------

echo
echo 'Script:  '$(basename $0)'  Script Version: '${ScriptVersion}'  Revision: '${ScriptRevision}'  Date: '${ScriptDate}
echo 'Script original call name :  '$0 $@
echo

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# Setup initial variables
# -------------------------------------------------------------------------------------------------


export localnamenow=${HOSTNAME}.`date +%Y-%m-%d-%H%M%S%Z`
#export localnamenow=${HOSTNAME}.`date +%Y-%m-%d`

export package_layer='threat-layers'

#export api_show_command='show threat-layer'
export api_show_command='show threat-rulebase'
#export api_show_command='show threat-rule-exception-rulebase'
#export api_show_command='show threat-profiles'

#export api_add_command='add threat-layer'
export api_add_command='add threat-rule'
#export api_add_command='add threat-exception'
#export api_add_command='add threat-profile'

#export commandfilename=${api_show_command// /_}
export commandfilename=${api_add_command// /_}
export commandfilename=${commandfilename//-/_}

#export showfileprefix=z.${commandfilename}
#export showfileext=json

export outfileprefix=${api_show_command#* }
#export outfileprefix=${api_add_command#* }
export outfileprefix=${outfileprefix//-/_}
export outfileprefix=zz.${outfileprefix}
export outfileext=csv

export resultsfileprefix=zzz_Results.import.${commandfilename}
export resultsfileext=json

# -------------------------------------------------------------------------------------------------

export tcol01=25

#printf "%-40s = %s\n" 'X' "${X}" >> ${logfilepath}
#printf "%-40s = %s\n" 'X' "${X}"
#printf "%-${tcol01}s = %s\n" 'X' "${X}" >> ${logfilepath}
#printf "%-${tcol01}s = %s\n" 'X' "${X}"
echo
#printf "%-${tcol01}s = %s\n" 'api_show_command' "${api_show_command}"
printf "%-${tcol01}s = %s\n" 'api_add_command' "${api_add_command}"
printf "%-${tcol01}s = %s\n" 'commandfilename' "${commandfilename}"
#printf "%-${tcol01}s = %s\n" 'showfileprefix' "${showfileprefix}"
#printf "%-${tcol01}s = %s\n" 'showfileext' "${showfileext}"
printf "%-${tcol01}s = %s\n" 'outfileprefix' "${outfileprefix}"
printf "%-${tcol01}s = %s\n" 'outfileext' "${outfileext}"
printf "%-${tcol01}s = %s\n" 'resultsfileprefix' "${resultsfileprefix}"
printf "%-${tcol01}s = %s\n" 'resultsfileext' "${resultsfileext}"
echo


# -------------------------------------------------------------------------------------------------
# Define Results Output file
# -------------------------------------------------------------------------------------------------


#export detaillevelset=standard
export detaillevelset=full
#export resultsfile=${resultsfileprefix}.${layerfilename}.${detaillevelset}.${HOSTNAME}.${localnamenow}.${resultsfileext}
export resultsfile=${resultsfileprefix}.${detaillevelset}.${HOSTNAME}.${localnamenow}.${resultsfileext}

printf "%-${tcol01}s = %s\n" 'resultsfile' "${resultsfile}"
printf "%-${tcol01}s = %s\n" 'resultsfile : '${detaillevelset} "${resultsfile}"
echo


# -------------------------------------------------------------------------------------------------
# Define Export Selection file
# -------------------------------------------------------------------------------------------------


export selectexportpath=./_import.csv
export selectexportfileprefix=${api_show_command#* }
#export selectexportfileprefix=${api_add_command#* }
export selectexportfileprefix=${selectexportfileprefix//-/_}
export selectexportfileprefix=*${selectexportfileprefix}.*.export
export selectexportfileext=${outfileext}
export selectexportfile=${selectexportfileprefix}.*.${selectexportfileext}

printf "%-${tcol01}s = %s\n" 'selectexportpath' "${selectexportpath}"
printf "%-${tcol01}s = %s\n" 'selectexportfileprefix' "${selectexportfileprefix}"
printf "%-${tcol01}s = %s\n" 'selectexportfileext' "${selectexportfileext}"
printf "%-${tcol01}s = %s\n" 'selectexportfile' "${selectexportfile}"
echo


# -------------------------------------------------------------------------------------------------
# Handle selection of specific layer to process
# -------------------------------------------------------------------------------------------------


export selectedfile=

echo
echo 'Select file for import processing ( 0 for exit/quit ): '

select selectedfile in `ls ${selectexportpath}/${selectexportfile}`;
do
    echo you picked ${selectedfile} \(${REPLY}\)
    break;
done

echo 'Selection:  selectedfile : ['${selectedfile}'],  REPLY : ['${REPLY}']'
echo

if [ x"${selectedfile}" == x"" ] ; then
    echo 'Not valid selection'
    echo 'Exiting...'
    echo
    exit 1
fi

if [ ${REPLY} -eq 0 ] ; then
    echo 'Exiting...'
    echo
    exit 0
fi

printf "%-${tcol01}s = %s\n" 'selectedfile' "${selectedfile}"
echo

# -------------------------------------------------------------------------------------------------
# Get the local API SSL port which may not be the default 443...
# -------------------------------------------------------------------------------------------------


pythonpath=${MDS_FWDIR}/Python/bin/
get_api_local_port=`${pythonpath}/python ${MDS_FWDIR}/scripts/api_get_port.py -f json | ${JQ} '. | .external_port'`
api_local_port=${get_api_local_port//\"/}
export apisslport=${api_local_port}


# -------------------------------------------------------------------------------------------------
# Configure Authentication
# -------------------------------------------------------------------------------------------------


#export MgmtCLI_Authentication='-s '${APICLIsessionfile}
export MgmtCLI_Authentication='-r true --port '${apisslport}


# -------------------------------------------------------------------------------------------------
# Generate working json file of API output for future processing
# -------------------------------------------------------------------------------------------------


#echo 'Generate working json file of API output for future processing...'

#export detaillevelset=standard
#export detaillevelset=full
#export showfile=${showfileprefix}.${layerfilename}.${detaillevelset}.${localnamenow}.${showfileext}
#export showfile=${showfileprefix}.${detaillevelset}.${localnamenow}.${showfileext}

#echo
#printf "%-${tcol01}s = %s\n" 'showfile' "${showfile}"
#printf "%-${tcol01}s = %s\n" 'showfile : '${detaillevelset} "${showfile}"
#echo

#export MgmtCLI_Base_OpParms='-f json'
#export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='details-level standard '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='use-object-dictionary false '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='limit 100 offset 0 '${MgmtCLI_Show_OpParms}

#mgmt_cli -r true --port ${apisslport} show threat-profiles limit 25 offset 0 details-level full --format json > "${showfile}"
#mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} ${MgmtCLI_Show_OpParms} > "${showfile}"

#echo '-------------------------------------------------------------------------------------------------'

#ls -alh ${showfile}

#echo '-------------------------------------------------------------------------------------------------'


# -------------------------------------------------------------------------------------------------
# Execute Threat Prevention Profiles import
# -------------------------------------------------------------------------------------------------


echo 'Execute Threat Prevention Profiles import'
echo

#export exportoutfileheader=${outfileprefix}.export.header.${outfileext}
#export exportoutfile=${outfileprefix}.export.${localnamenow}.${outfileext}

export MgmtCLI_Base_OpParms='--ignore-errors true -f json'
export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='details-level standard '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='use-object-dictionary false '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='limit 100 offset 0 '${MgmtCLI_Show_OpParms}

#mgmt_cli -r true add threat-rule --batch ./z.threat_rulebase.LAYER.export.HOSTNAME.DTGSZ.csv details-level full -f json | tee -a import_threat_rules_${HOSTNAME}_`date +%Y-%m-%d-%H%M%S%Z`.json
mgmt_cli ${MgmtCLI_Authentication} ${api_add_command} --batch ./${selectedfile} ${MgmtCLI_Show_OpParms} | tee -a ${resultsfile}

echo '-------------------------------------------------------------------------------------------------'

#cat ${exportoutfile}


# -------------------------------------------------------------------------------------------------
# Wrap Up
# -------------------------------------------------------------------------------------------------


echo
echo 'Operations completed!'
echo

ls -alh *.json
ls -alh *.csv

