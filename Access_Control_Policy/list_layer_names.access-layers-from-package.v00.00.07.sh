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
# SCRIPT Rough Example for generating a list of layers from package for selection of a specific layer for show output - Access Control layers
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

export package_layer='access-layers'
#export package_layer='threat-layers'

export api_show_command='show access-layer'
#export api_show_command='show access-layers'
#export api_show_command='show access-rulebase'
#export api_show_command='show threat-layer'
#export api_show_command='show threat-rulebase'
#export api_show_command='show threat-rule-exception-rulebase'
#export api_show_command='show threat-profiles'

export commandfilename=${api_show_command// /_}
export commandfilename=${commandfilename//-/_}

export showfileprefix=z.${commandfilename}
export showfileext=json
#export outfileprefix='z.access-layer'
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
export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='limit 50 offset 0 '${MgmtCLI_Show_OpParms}

GETLAYERSBYNAME="`mgmt_cli ${MgmtCLI_Authentication} show packages ${MgmtCLI_Show_OpParms} | ${JQ} '.packages[]."'${package_layer}'"[].name'`"

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
#export MgmtCLI_Show_OpParms='details-level full use-object-dictionary false '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='limit 100 offset 0 '${MgmtCLI_Show_OpParms}

#mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} ${MgmtCLI_Show_OpParms} > "${showfile}"
mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} name "${layername}" ${MgmtCLI_Show_OpParms} > "${showfile}"
#mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} name "${layername}" rule-number 1 ${MgmtCLI_Show_OpParms} > "${showfile}"

echo '-------------------------------------------------------------------------------------------------'

ls -alh ${showfile}

echo '-------------------------------------------------------------------------------------------------'


# -------------------------------------------------------------------------------------------------
# 
# -------------------------------------------------------------------------------------------------




# -------------------------------------------------------------------------------------------------
# Wrap Up
# -------------------------------------------------------------------------------------------------


echo
echo 'Operations completed!'
echo

ls -alh *.json
#ls -alh *.csv

