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
# SCRIPT Rough Example for exporting threat prevention rulebase for a specific layer
#
#

ScriptVersion=00.00.07
ScriptRevision=000
ScriptDate=2021-06-09
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

export commandfilename=${api_show_command// /_}
export commandfilename=${commandfilename//-/_}

export showfileprefix=z.${commandfilename}
export showfileext=json
#export outfileprefix='z.threat-rulebase'
export outfileprefix=${api_show_command#* }
export outfileprefix=${outfileprefix//-/_}
export outfileprefix=zz.${outfileprefix}
export outfileext=csv

echo
echo 'api_show_command   = '"${api_show_command}"
echo 'commandfilename    = '"${commandfilename}"
echo 'showfileprefix     = '"${showfileprefix}"
echo 'showfileext        = '"${showfileext}"
echo 'outfileprefix      = '"${outfileprefix}"
echo 'outfileext         = '"${outfileext}"
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
# Get the Array of layers
# -------------------------------------------------------------------------------------------------


echo 'Generate Array of Layers...'
echo

export MgmtCLI_Base_OpParms='-f json'
#export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='details-level standard '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='limit 500 offset 0 '${MgmtCLI_Show_OpParms}

GETLAYERSBYNAME="`mgmt_cli ${MgmtCLI_Authentication} show ${package_layer} ${MgmtCLI_Show_OpParms} | ${JQ} '."'${package_layer}'"[].name'`"

LAYERSARRAY=()
arraylength=0

echo 'Layers ('${package_layer}') :  '
while read -r line; do
    
    if [[ ! " ${LAYERSARRAY[@]} " =~ " ${line} " ]]; then
        # whatever you want to do when array doesn't contain value
        LAYERSARRAY+=("${line}")
        echo 'ADDING - '${line}
    else
        echo 'SKIPPING - '${line}
    fi
    
    #if [ "${line}" == 'something-to-omit' ]; then
    #    echo -n 'Not adding '${line}
    #else 
    #    LAYERSARRAY+=("${line}")
    #    echo -n ${line}
    #fi
    
    arraylength=${#LAYERSARRAY[@]}
    arrayelement=$((arraylength-1))
    
done <<< "${GETLAYERSBYNAME}"
echo

export arraylistsize=${arrayelement}


# -------------------------------------------------------------------------------------------------
# Document/show the current array of layers found and placed in the array
# -------------------------------------------------------------------------------------------------


#echo 'Explicit Layers of type '${package_layer}' found: '
#export arraylistelement=-1
#for j in "${LAYERSARRAY[@]}"
#do
    #export arraylistelement=$((arraylistelement+1))
    #echo "${arraylistelement} : ${j}"
#done
#echo


# -------------------------------------------------------------------------------------------------
# Handle selection of specific layer to process
# -------------------------------------------------------------------------------------------------


export arrayelementchoice=
export layername=

echo
echo 'Select Layer of type '${package_layer}' for processing ( 0 for exit/quit ): '

select layername in "${LAYERSARRAY[@]}";
do
    echo you picked ${layername} \(${REPLY}\)
    break;
done

echo 'Selection:  layername : ['${layername}'],  REPLY : ['${REPLY}']'
echo

if [ x"${layername}" == x"" ] ; then
    echo 'Not legal selection'
    echo 'Exiting...'
    echo
    exit 1
fi

if [ ${REPLY} -eq 0 ] ; then
    echo 'Exiting...'
    echo
    exit 0
fi

export arrayelementchoice=$((REPLY-1))


# -------------------------------------------------------------------------------------------------
# Show what was selected and names of things
# -------------------------------------------------------------------------------------------------


export layerfilename=${layername// /_}
export layerfilename=${layerfilename//\"}

echo
echo 'arraylistsize       = '${arraylistsize}
echo 'layer array choice  = '${arrayelementchoice}
echo 'layername           = '"${layername}"
echo 'layerfilename       = '"${layerfilename}"
echo


# -------------------------------------------------------------------------------------------------
# Generate working json file of API output for future processing
# -------------------------------------------------------------------------------------------------


echo 'Generate working json file of API output for future processing...'

#export detaillevelset=standard
export detaillevelset=full
export showfile=${showfileprefix}.${layerfilename}.${detaillevelset}.${localnamenow}.${showfileext}
#export showfile=${showfileprefix}.${detaillevelset}.${localnamenow}.${showfileext}

echo
#echo 'showfile           = '"${showfile}"
#echo 'showfile : standard = '"${showfile}"
echo 'showfile : full     = '"${showfile}"
echo

export MgmtCLI_Base_OpParms='-f json'
export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='details-level standard '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='use-object-dictionary false '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='limit 500 offset 0 '${MgmtCLI_Show_OpParms}

#mgmt_cli -r true show threat-rulebase name "${layername}" limit 500 offset 0 use-object-dictionary false details-level full -f json > "${showfile}"
mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} name "${layername}" ${MgmtCLI_Show_OpParms} > "${showfile}"

# -------------------------------------------------------------------------------------------------

export detaillevelset=standard
#export detaillevelset=full
export showfile=${showfileprefix}.${layerfilename}.${detaillevelset}.${localnamenow}.${showfileext}
#export showfile=${showfileprefix}.${detaillevelset}.${localnamenow}.${showfileext}

echo
#echo 'showfile           = '"${showfile}"
echo 'showfile : standard = '"${showfile}"
#echo 'showfile : full     = '"${showfile}"
echo

export MgmtCLI_Base_OpParms='-f json'
#export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='details-level standard '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='use-object-dictionary false '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='limit 500 offset 0 '${MgmtCLI_Show_OpParms}

#mgmt_cli -r true show threat-rulebase name "${layername}" limit 500 offset 0 use-object-dictionary false details-level standard -f json > "${showfile}"
mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} name "${layername}" ${MgmtCLI_Show_OpParms} > "${showfile}"

echo '-------------------------------------------------------------------------------------------------'

ls -alh ${showfile}

echo '-------------------------------------------------------------------------------------------------'


# -------------------------------------------------------------------------------------------------
# Generate Threat Prevention Rulebase detailed export for reference
# -------------------------------------------------------------------------------------------------


echo 'Generate Threat Prevention Rulebase detailed export for reference'
echo

export outfileheader=${outfileprefix}.FOR_REFERENCE_ONLY.header.${outfileext}

#echo '"layer", "exception-group-name", "name", "type", "exception-number", "source.0.name", "source.0.type", "source.1.name", "source.1.type", "source-negate", "destination.0.name", "destination.0.type", "destination.1.name", "destination.1.type", "destination-negate", "protected-scope.0.name", "protected-scope.0.type", "protected-scope.1.name", "protected-scope.0.type", "protected-scope-negate", "protection-or-site.0.name", "protection-or-site.0.type", "protection-or-site.1.name", "protection-or-site.1.type", "protection-or-site.2.name", "protection-or-site.2.type", "track.name", "action.name", "enabled", "comments", "install-on.0.name", "install-on.0.type"' > test_global_exceptions.header.csv

#export csvheader=''
#export csvheader=${csvheader}', '

export csvheader='"layer"'
export csvheader=${csvheader}', "name", "rule-number"'
export csvheader=${csvheader}', "source.0.name", "source.0.type"'
export csvheader=${csvheader}', "source.1.name", "source.1.type"'
export csvheader=${csvheader}', "source.2.name", "source.2.type"'
export csvheader=${csvheader}', "source.3.name", "source.3.type"'
export csvheader=${csvheader}', "source.4.name", "source.4.type"'
export csvheader=${csvheader}', "source.5.name", "source.5.type"'
export csvheader=${csvheader}', "source-negate"'
export csvheader=${csvheader}', "destination.0.name", "destination.0.type"'
export csvheader=${csvheader}', "destination.1.name", "destination.1.type"'
export csvheader=${csvheader}', "destination.2.name", "destination.2.type"'
export csvheader=${csvheader}', "destination.3.name", "destination.3.type"'
export csvheader=${csvheader}', "destination.4.name", "destination.4.type"'
export csvheader=${csvheader}', "destination.5.name", "destination.5.type"'
export csvheader=${csvheader}', "destination-negate"'
export csvheader=${csvheader}', "service.0.name", "service.0.type"'
export csvheader=${csvheader}', "service.1.name", "service.1.type"'
export csvheader=${csvheader}', "service.2.name", "service.2.type"'
export csvheader=${csvheader}', "service.3.name", "service.3.type"'
export csvheader=${csvheader}', "service.4.name", "service.4.type"'
export csvheader=${csvheader}', "service.5.name", "service.5.type"'
export csvheader=${csvheader}', "service-negate"'
export csvheader=${csvheader}', "protected-scope.0.name", "protected-scope.0.type"'
export csvheader=${csvheader}', "protected-scope.1.name", "protected-scope.1.type"'
export csvheader=${csvheader}', "protected-scope.2.name", "protected-scope.2.type"'
export csvheader=${csvheader}', "protected-scope.3.name", "protected-scope.3.type"'
export csvheader=${csvheader}', "protected-scope.4.name", "protected-scope.4.type"'
export csvheader=${csvheader}', "protected-scope.5.name", "protected-scope.5.type"'
export csvheader=${csvheader}', "protected-scope-negate"'
export csvheader=${csvheader}', "track.name", "track-settings.packet-capture"'
export csvheader=${csvheader}', "action.name", "action.type"'
export csvheader=${csvheader}', "enabled", "comments"'
export csvheader=${csvheader}', "install-on.0.name", "install-on.0.type"'

echo ${csvheader} > ${outfileheader}

echo
echo 'csvheader     = '${csvheader} 
echo


#export jsonvaluekeys='.["name"], .["type"], .["exception-number"], .["source"][0]["name"], .["source"][0]["type"], .["source"][1]["name"], .["source"][1]["type"], .["source-negate"], .["destination"][0]["name"], .["destination"][0]["type"], .["destination"][1]["name"], .["destination"][1]["type"], .["destination-negate"], .["protected-scope"][0]["name"], .["protected-scope"][0]["type"], .["protected-scope"][1]["name"], .["protected-scope"][0]["type"], .["protected-scope-negate"], .["protection-or-site"][0]["name"], .["protection-or-site"][0]["type"], .["protection-or-site"][1]["name"], .["protection-or-site"][1]["type"], .["protection-or-site"][2]["name"], .["protection-or-site"][2]["type"], .["track"]["name"], .["action"]["name"], .["enabled"], .["comments"], .["install-on"][0]["name"], .["install-on"][0]["type"]'

#export jsonvaluekeys=''
#export jsonvaluekeys=${jsonvaluekeys}', '

export jsonvaluekeys="${layername}"
export jsonvaluekeys=${jsonvaluekeys}', .["name"], .["rule-number"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][0]["name"], .["source"][0]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][1]["name"], .["source"][1]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][2]["name"], .["source"][2]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][3]["name"], .["source"][3]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][4]["name"], .["source"][4]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][5]["name"], .["source"][5]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][0]["name"], .["destination"][0]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][1]["name"], .["destination"][1]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][2]["name"], .["destination"][2]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][3]["name"], .["destination"][3]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][4]["name"], .["destination"][4]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][5]["name"], .["destination"][5]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][0]["name"], .["service"][0]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][1]["name"], .["service"][1]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][2]["name"], .["service"][2]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][3]["name"], .["service"][3]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][4]["name"], .["service"][4]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][5]["name"], .["service"][5]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][0]["name"], .["protected-scope"][0]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][1]["name"], .["protected-scope"][1]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][2]["name"], .["protected-scope"][2]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][3]["name"], .["protected-scope"][3]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][4]["name"], .["protected-scope"][4]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][5]["name"], .["protected-scope"][5]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["track"]["name"], .["track-settings"]["packet-capture"]'
export jsonvaluekeys=${jsonvaluekeys}', .["action"]["name"], .["action"]["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["enabled"], .["comments"]'
export jsonvaluekeys=${jsonvaluekeys}', .["install-on"][0]["name"], .["install-on"][0]["type"]'

echo
echo 'jsonvaluekeys = '${jsonvaluekeys} 
echo

export outfile=z.threat_rulebase.${layerfilename}.FOR_REFERENCE_ONLY.${localnamenow}.csv

cat ${outfileheader} > ${outfile} 

cat ${showfile} | ${JQ} -r '.rulebase[] | [ '"${jsonvaluekeys}"' ] | @csv ' >> ${outfile} 

echo '-------------------------------------------------------------------------------------------------'

#cat ${outfile}


# -------------------------------------------------------------------------------------------------
# Generate Threat Prevention Rulebase detailed export for actual import
# -------------------------------------------------------------------------------------------------


echo 'Generate Threat Prevention Rulebase detailed export for actual import'
echo

export exportoutfileheader=${outfileprefix}.export.header.${outfileext}

#echo '"layer", "exception-group-name", "name", "type", "exception-number", "source.0.name", "source.0.type", "source.1.name", "source.1.type", "source-negate", "destination.0.name", "destination.0.type", "destination.1.name", "destination.1.type", "destination-negate", "protected-scope.0.name", "protected-scope.0.type", "protected-scope.1.name", "protected-scope.0.type", "protected-scope-negate", "protection-or-site.0.name", "protection-or-site.0.type", "protection-or-site.1.name", "protection-or-site.1.type", "protection-or-site.2.name", "protection-or-site.2.type", "track.name", "action.name", "enabled", "comments", "install-on.0.name", "install-on.0.type"' > test_global_exceptions.header.csv

#export csvheader=''
#export csvheader=${csvheader}', '

export csvheader='"layer"'
export csvheader=${csvheader}', "name", "position"'
export csvheader=${csvheader}', "source.0"'
export csvheader=${csvheader}', "source.1"'
export csvheader=${csvheader}', "source.2"'
export csvheader=${csvheader}', "source.3"'
export csvheader=${csvheader}', "source.4"'
export csvheader=${csvheader}', "source.5"'
export csvheader=${csvheader}', "source-negate"'
export csvheader=${csvheader}', "destination.0"'
export csvheader=${csvheader}', "destination.1"'
export csvheader=${csvheader}', "destination.2"'
export csvheader=${csvheader}', "destination.3"'
export csvheader=${csvheader}', "destination.4"'
export csvheader=${csvheader}', "destination.5"'
export csvheader=${csvheader}', "destination-negate"'
export csvheader=${csvheader}', "service.0"'
export csvheader=${csvheader}', "service.1"'
export csvheader=${csvheader}', "service.2"'
export csvheader=${csvheader}', "service.3"'
export csvheader=${csvheader}', "service.4"'
export csvheader=${csvheader}', "service.5"'
export csvheader=${csvheader}', "service-negate"'
export csvheader=${csvheader}', "protected-scope.0"'
export csvheader=${csvheader}', "protected-scope.1"'
export csvheader=${csvheader}', "protected-scope.2"'
export csvheader=${csvheader}', "protected-scope.3"'
export csvheader=${csvheader}', "protected-scope.4"'
export csvheader=${csvheader}', "protected-scope.5"'
export csvheader=${csvheader}', "protected-scope-negate"'
export csvheader=${csvheader}', "track", "track-settings.packet-capture"'
export csvheader=${csvheader}', "action"'
export csvheader=${csvheader}', "enabled", "comments"'
export csvheader=${csvheader}', "install-on.0"'
export csvheader=${csvheader}', "ignore-warnings", "ignore-errors"'

echo ${csvheader} > ${exportoutfileheader}

echo
echo 'csvheader     = '${csvheader} 
echo


#export jsonvaluekeys='.["name"], .["type"], .["exception-number"], .["source"][0]["name"], .["source"][0]["type"], .["source"][1]["name"], .["source"][1]["type"], .["source-negate"], .["destination"][0]["name"], .["destination"][0]["type"], .["destination"][1]["name"], .["destination"][1]["type"], .["destination-negate"], .["protected-scope"][0]["name"], .["protected-scope"][0]["type"], .["protected-scope"][1]["name"], .["protected-scope"][0]["type"], .["protected-scope-negate"], .["protection-or-site"][0]["name"], .["protection-or-site"][0]["type"], .["protection-or-site"][1]["name"], .["protection-or-site"][1]["type"], .["protection-or-site"][2]["name"], .["protection-or-site"][2]["type"], .["track"]["name"], .["action"]["name"], .["enabled"], .["comments"], .["install-on"][0]["name"], .["install-on"][0]["type"]'

#export jsonvaluekeys=''
#export jsonvaluekeys=${jsonvaluekeys}', '

export jsonvaluekeys="${layername}"
export jsonvaluekeys=${jsonvaluekeys}', .["name"], .["rule-number"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][0]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][1]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][2]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][4]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source"][5]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["source-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][0]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][1]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][2]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][4]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination"][5]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["destination-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][0]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][1]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][2]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][4]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service"][5]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["service-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][0]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][1]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][2]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][4]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope"][5]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["protected-scope-negate"]'
export jsonvaluekeys=${jsonvaluekeys}', .["track"]["name"], .["track-settings"]["packet-capture"]'
export jsonvaluekeys=${jsonvaluekeys}', .["action"]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["enabled"], .["comments"]'
export jsonvaluekeys=${jsonvaluekeys}', .["install-on"][0]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', true, true'

echo
echo 'jsonvaluekeys = '${jsonvaluekeys} 
echo

export exportoutfile=z.threat_rulebase.${layerfilename}.export.${localnamenow}.csv

cat ${exportoutfileheader} > ${exportoutfile} 

cat ${showfile} | ${JQ} -r '.rulebase[] | [ '"${jsonvaluekeys}"' ] | @csv ' >> ${exportoutfile} 

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

