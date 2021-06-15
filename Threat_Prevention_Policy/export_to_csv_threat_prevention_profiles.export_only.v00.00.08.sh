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
# SCRIPT Rough Example for exporting threat prevention profiles - export only
#
#

ScriptVersion=00.00.08
ScriptRevision=000
ScriptDate=2021-06-14
TemplateVersion=@NA
APISubscriptsLevel=@NA
APISubscriptsVersion=@NA
APISubscriptsRevision=@NA

#


# -------------------------------------------------------------------------------------------------
# Setup root parameters ...
# -------------------------------------------------------------------------------------------------


export DATEDTG=`date +%Y-%m-%d-%H%M%Z`
export DATEDTGS=`date +%Y-%m-%d-%H%M%S%Z`

export tcol01=25

export pythonpath=${MDS_FWDIR}/Python/bin/

export forreferenceonlytext=FOR_REFERENCE_ONLY
export outputpathroot=./_output
export exportpathroot=./_export
export importpathroot=./_import


# -------------------------------------------------------------------------------------------------
# Logging configuration
# -------------------------------------------------------------------------------------------------

#export logfilepath=${outputpathroot}/$(basename $0)'_'${ScriptVersion}'_'${DATEDTGS}.log
export logfilepath=${outputpathroot}/$(basename $0)'_'${DATEDTGS}.log

if [ ! -r ${outputpathroot} ] ; then
    mkdir -pv ${outputpathroot}
    chmod 775 ${outputpathroot}
else
    chmod 775 ${outputpathroot}
fi


# -------------------------------------------------------------------------------------------------
# Announce what we are starting here...
# -------------------------------------------------------------------------------------------------

echo | tee -a -i ${logfilepath}
echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
echo 'Script:  '$(basename $0)'  Script Version: '${ScriptVersion}'  Revision: '${ScriptRevision}'  Date: '${ScriptDate} | tee -a -i ${logfilepath}
echo 'Script original call name :  '$0 $@ | tee -a -i ${logfilepath}
echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}


# -------------------------------------------------------------------------------------------------
# Get the local Check Point Release version of the current host...
# -------------------------------------------------------------------------------------------------


export gaiaversion=
cpreleasefile=/etc/cp-release
if [ -r ${cpreleasefile} ] ; then
    # OK we have the easy-button alternative
    export gaiaversion=$(cat ${cpreleasefile} | cut -d " " -f 4)
else
    # OK that's not going to work without the file
    
    get_platform_release=`${pythonpath}/python ${MDS_FWDIR}/scripts/get_platform.py -f json | ${CPDIR_PATH}/jq/jq '. | .release'`
    
    platform_release=${get_platform_release//\"/}
    get_platform_release_version=`echo ${platform_release} | cut -d " " -f 4`
    platform_release_version=${get_platform_release_version//\"/}
    
    export gaiaversion=${platform_release_version}
fi

#printf "%-${tcol01}s = %s\n" 'X' "${X}"  | tee -a -i ${logfilepath}
printf "%-${tcol01}s = %s\n" 'Gaia Release Version' "${gaiaversion}" | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}


# -------------------------------------------------------------------------------------------------
# Get the local API SSL port which may not be the default 443...
# -------------------------------------------------------------------------------------------------


get_api_local_port=`${pythonpath}/python ${MDS_FWDIR}/scripts/api_get_port.py -f json | ${CPDIR_PATH}/jq/jq '. | .external_port'`
api_local_port=${get_api_local_port//\"/}
export apisslport=${api_local_port}

#printf "%-${tcol01}s = %s\n" 'X' "${X}" | tee -a -i ${logfilepath}
printf "%-${tcol01}s = %s\n" 'API SSL Port' "${apisslport}" | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}


# -------------------------------------------------------------------------------------------------
# Setup control variables
# -------------------------------------------------------------------------------------------------


#
# Policy Type configuration for script.  ONE of these needs to be true, all others false
# Options:  true | false
#
export policy_type_Access=false
export policy_type_Threat=true
export policy_type_HTTPSI=false

#
# Script Operation Type configuration for script.  ONE of these needs to be true, all others false
# Options:  export | import | list_layers
#
#export script_operation=list_layers
#export script_operation=export
export script_operation=export_only
#export script_operation=import

#export api_show_command=
#export api_show_command='show access-layer'
#export api_show_command='show access-layers'
#export api_show_command='show access-rulebase'
#export api_show_command='show threat-layer'
#export api_show_command='show threat-rulebase'
#export api_show_command='show threat-rule-exception-rulebase'
export api_show_command='show threat-profiles'

export api_add_command=
#export api_add_command='add threat-layer'
#export api_add_command='add threat-rule'
#export api_add_command='add threat-exception'
#export api_add_command='add threat-profile'

export commandfilename=${api_show_command// /_}
#export commandfilename=${api_add_command// /_}
export commandfilename=${commandfilename//-/_}

export apicommandtarget=${api_show_command#* }
#export apicommandtarget=${api_add_command#* }
export apicommandtarget=${apicommandtarget//-/_}

#
# Configure what we are using for the working files for show, export, import, and results
#
export use_showfile=false
export use_exportfile=false
export use_exportfile4ref=false
export use_importfile=false
export use_resultsfile=false

case "${script_operation}" in
    # list layers
    'list_layers' )
        export use_showfile=true
        export use_exportfile=false
        export use_exportfile4ref=false
        export use_importfile=false
        export use_resultsfile=false
        ;;
    # export
    'export' )
        export use_showfile=true
        export use_exportfile=true
        export use_exportfile4ref=true
        export use_importfile=false
        export use_resultsfile=false
        ;;
    # export_only
    'export_only' )
        export use_showfile=true
        export use_exportfile=true
        export use_exportfile4ref=false
        export use_importfile=false
        export use_resultsfile=false
        ;;
    # import
    'import' )
        export use_showfile=false
        export use_exportfile=false
        export use_exportfile4ref=false
        export use_importfile=true
        export use_resultsfile=true
        ;;
    # Anything unknown is recorded for later
    * )
        export policy_type_Access=false
        export policy_type_Threat=false
        export policy_type_HTTPSI=false
        
        export use_showfile=false
        export use_exportfile=false
        export use_exportfile4ref=false
        export use_importfile=false
        export use_resultsfile=false
        
        echo 'Script configuration error!  Missing valid script operation type configuration value!'
        printf "%-${tcol01}s = %s\n" 'script_operation' "${script_operation}"
        echo 'Exiting! ...'
        echo
        exit 1
        ;;
esac

printf "%-${tcol01}s = %s\n" 'policy_type_Access' "${policy_type_Access}" >> ${logfilepath}
printf "%-${tcol01}s = %s\n" 'policy_type_Threat' "${policy_type_Threat}" >> ${logfilepath}
printf "%-${tcol01}s = %s\n" 'policy_type_HTTPSI' "${policy_type_HTTPSI}" >> ${logfilepath}
printf "%-${tcol01}s = %s\n" 'script_operation' "${script_operation}" | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}
printf "%-${tcol01}s = %s\n" 'use_showfile' "${use_showfile}" >> ${logfilepath}
printf "%-${tcol01}s = %s\n" 'use_exportfile' "${use_exportfile}" >> ${logfilepath}
printf "%-${tcol01}s = %s\n" 'use_exportfile4ref' "${use_exportfile4ref}" >> ${logfilepath}
printf "%-${tcol01}s = %s\n" 'use_importfile' "${use_importfile}" >> ${logfilepath}
printf "%-${tcol01}s = %s\n" 'use_resultsfile' "${use_resultsfile}" >> ${logfilepath}
echo >> ${logfilepath}


# -------------------------------------------------------------------------------------------------
# Setup initial variables
# -------------------------------------------------------------------------------------------------


export localnamenow=${HOSTNAME}.${gaiaversion}.${DATEDTGS}
export localnametoday=${HOSTNAME}.${gaiaversion}.`date +%Y-%m-%d`

if ${policy_type_Access} ; then
    export package_layer='access-layers'
elif ${policy_type_Threat} ; then
    export package_layer='threat-layers'
elif ${policy_type_HTTPSI} ; then
    export package_layer='https-layers'
else
    # what?
    echo 'Script configuration error!  Missing valid policy type configuration boolean!'
    printf "%-${tcol01}s = %s\n" 'script_operation' "${script_operation}"
    printf "%-${tcol01}s = %s\n" 'policy_type_Access' "${policy_type_Access}"
    printf "%-${tcol01}s = %s\n" 'policy_type_Threat' "${policy_type_Threat}"
    printf "%-${tcol01}s = %s\n" 'policy_type_HTTPSI' "${policy_type_HTTPSI}"
    echo 'Exiting! ...'
    echo
    exit 1
fi

export showfileprefix=z.${commandfilename}
export showfileext=json
export showfilepath=${outputpathroot}.${showfileext}

export exportfileprefix=zz.${apicommandtarget}
export exportfileext=csv
export exportfilepath=${exportpathroot}.${exportfileext}
export exportfilepath4reference=${exportpathroot}.${exportfileext}.${forreferenceonlytext}

export importfileslistprefix=*${apicommandtarget}
export importfileprefix=zz.${apicommandtarget}
export importfileext=csv
export importfilepath=${importpathroot}.${importfileext}

export resultsfileprefix=zzz_Results.export.${commandfilename}
export resultsfileext=json
export resultsfilepath=${outputpathroot}

# -------------------------------------------------------------------------------------------------

#printf "%-40s = %s\n" 'X' "${X}" | tee -a -i ${logfilepath}
#printf "%-${tcol01}s = %s\n" 'X' "${X}" | tee -a -i ${logfilepath}

echo | tee -a -i ${logfilepath}

printf "%-${tcol01}s = %s\n" 'apicommandtarget' "${apicommandtarget}" | tee -a -i ${logfilepath}
if [ ! -z "${api_show_command}" ] ; then
    printf "%-${tcol01}s = %s\n" 'api_show_command' "${api_show_command}" | tee -a -i ${logfilepath}
fi
if [ ! -z "${api_add_command}" ] ; then
    printf "%-${tcol01}s = %s\n" 'api_add_command' "${api_add_command}" | tee -a -i ${logfilepath}
fi
printf "%-${tcol01}s = %s\n" 'commandfilename' "${commandfilename}" | tee -a -i ${logfilepath}
if ${use_showfile} ; then
    printf "%-${tcol01}s = %s\n" 'showfileprefix' "${showfileprefix}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'showfileext' "${showfileext}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'showfilepath' "${showfilepath}" | tee -a -i ${logfilepath}
fi
if ${use_exportfile} ; then
    printf "%-${tcol01}s = %s\n" 'exportfileprefix' "${exportfileprefix}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'exportfileext' "${exportfileext}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'exportfilepath' "${exportfilepath}" | tee -a -i ${logfilepath}
fi
if ${use_exportfile4ref} ; then
    printf "%-${tcol01}s = %s\n" 'exportfilepath4reference' "${exportfilepath4reference}" | tee -a -i ${logfilepath}
fi
if ${use_importfile} ; then
    printf "%-${tcol01}s = %s\n" 'importfileslistprefix' "${importfileslistprefix}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'importfileprefix' "${importfileprefix}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'importfileext' "${importfileext}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'importfilepath' "${importfilepath}" | tee -a -i ${logfilepath}
fi
if ${use_resultsfile} ; then
    printf "%-${tcol01}s = %s\n" 'resultsfileprefix' "${resultsfileprefix}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'resultsfileext' "${resultsfileext}" | tee -a -i ${logfilepath}
    printf "%-${tcol01}s = %s\n" 'resultsfilepath' "${resultsfilepath}" | tee -a -i ${logfilepath}
fi
echo | tee -a -i ${logfilepath}


# -------------------------------------------------------------------------------------------------
# Make sure working folders exist
# -------------------------------------------------------------------------------------------------


if ${use_showfile} ; then
    if [ ! -r ${showfilepath} ] ; then
        mkdir -pv ${showfilepath} | tee -a -i ${logfilepath}
        chmod 775 ${showfilepath} | tee -a -i ${logfilepath}
    else
        chmod 775 ${showfilepath} | tee -a -i ${logfilepath}
    fi
fi

if ${use_exportfile} ; then
    if [ ! -r ${exportfilepath} ] ; then
        mkdir -pv ${exportfilepath} | tee -a -i ${logfilepath}
        chmod 775 ${exportfilepath} | tee -a -i ${logfilepath}
    else
        chmod 775 ${exportfilepath} | tee -a -i ${logfilepath}
    fi
fi
if ${use_exportfile4ref} ; then
    if [ ! -r ${exportfilepath4reference} ] ; then
        mkdir -pv ${exportfilepath4reference} | tee -a -i ${logfilepath}
        chmod 775 ${exportfilepath4reference} | tee -a -i ${logfilepath}
    else
        chmod 775 ${exportfilepath4reference} | tee -a -i ${logfilepath}
    fi
fi

if ${use_importfile} ; then
    if [ ! -r ${resultsfilepath} ] ; then
        mkdir -pv ${resultsfilepath} | tee -a -i ${logfilepath}
        chmod 775 ${resultsfilepath} | tee -a -i ${logfilepath}
    else
        chmod 775 ${resultsfilepath} | tee -a -i ${logfilepath}
    fi
fi

if ${use_resultsfile} ; then
    if [ ! -r ${importfilepath} ] ; then
        mkdir -pv ${importfilepath} | tee -a -i ${logfilepath}
        chmod 775 ${importfilepath} | tee -a -i ${logfilepath}
    else
        chmod 775 ${importfilepath} | tee -a -i ${logfilepath}
    fi
fi


# -------------------------------------------------------------------------------------------------
# Configure Authentication
# -------------------------------------------------------------------------------------------------


#export MgmtCLI_Authentication='-s '${APICLIsessionfile}
export MgmtCLI_Authentication='-r true --port '${apisslport}


# -------------------------------------------------------------------------------------------------
# Show what was selected and names of things
# -------------------------------------------------------------------------------------------------


#echo


# -------------------------------------------------------------------------------------------------
# Generate working json file of API output for future processing
# -------------------------------------------------------------------------------------------------


echo 'Generate working json file of API output for future processing...' | tee -a -i ${logfilepath}

#export detaillevelset=standard
export detaillevelset=full
#export showfile=${showfilepath}/${showfileprefix}.${layerfilename}.${detaillevelset}.${localnamenow}.${showfileext}
export showfile=${showfilepath}/${showfileprefix}.${detaillevelset}.${localnamenow}.${showfileext}

echo
#printf "%-${tcol01}s = %s\n" 'showfile' "${showfile}"
printf "%-${tcol01}s = %s\n" 'showfile : '${detaillevelset} "${showfile}"
echo

export MgmtCLI_Base_OpParms='-f json'
export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='details-level standard '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='use-object-dictionary false '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='limit 100 offset 0 '${MgmtCLI_Show_OpParms}

#mgmt_cli -r true --port ${apisslport} show threat-profiles limit 25 offset 0 details-level full --format json > "${showfile}"
mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} ${MgmtCLI_Show_OpParms} > "${showfile}"

echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}

ls -alh ${showfile} | tee -a -i ${logfilepath}

echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}


# -------------------------------------------------------------------------------------------------
# Generate Threat Prevention Profiles detailed export for actual import
# -------------------------------------------------------------------------------------------------


echo 'Generate Threat Prevention Profiles detailed export for actual import' | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}

#export exportexportfileheader=${exportfilepath}/${exportfileprefix}.export.header.${exportfileext}

export exportexportfile=${exportfilepath}/${exportfileprefix}.export.${localnamenow}.${exportfileext}


#export csvheader=''
#export csvheader=${csvheader}', '

export csvheader=''
#export csvheader=${csvheader}', "name"'
export csvheader=${csvheader}'"name", "color", "comments"'
export csvheader=${csvheader}', "active-protections-performance-impact", "active-protections-severity"'
export csvheader=${csvheader}', "confidence-level-low", "confidence-level-medium", "confidence-level-high"'
export csvheader=${csvheader}', "ips"'
export csvheader=${csvheader}', "ips-settings.newly-updated-protections", "ips-settings.exclude-protection-with-performance-impact", "ips-settings.exclude-protection-with-severity"'
export csvheader=${csvheader}', "malicious-mail-policy-settings.email-action", "malicious-mail-policy-settings.remove-attachments-and-links", "malicious-mail-policy-settings.malicious-attachments-text", "malicious-mail-policy-settings.failed-to-scan-attachments-text", "malicious-mail-policy-settings.malicious-links-text", "malicious-mail-policy-settings.add-x-header-to-email"'
export csvheader=${csvheader}', "malicious-mail-policy-settings.add-email-subject-prefix", "malicious-mail-policy-settings.email-subject-prefix-text", "malicious-mail-policy-settings.add-customized-text-to-email-body", "malicious-mail-policy-settings.email-body-customized-text", "malicious-mail-policy-settings.send-copy"'
export csvheader=${csvheader}', "scan-malicious-links.max-bytes", "scan-malicious-links.max-links"'
export csvheader=${csvheader}', "threat-emulation", "anti-virus", "anti-bot"'
export csvheader=${csvheader}', "overrides.0.protection", "overrides.0.action", "overrides.0.track", "overrides.0.capture-packets"'
export csvheader=${csvheader}', "overrides.1.protection", "overrides.1.action", "overrides.1.track", "overrides.1.capture-packets"'
export csvheader=${csvheader}', "use-extended-attributes"'
#export csvheader=${csvheader}', "activate-protections-by-extended-attributes.0.name", "activate-protections-by-extended-attributes.0.values.0.name", "activate-protections-by-extended-attributes.0.values.1.name", "activate-protections-by-extended-attributes.0.values.2.name", "activate-protections-by-extended-attributes.0.values.3.name"'
#export csvheader=${csvheader}', "activate-protections-by-extended-attributes.1.name", "activate-protections-by-extended-attributes.1.values.0.name", "activate-protections-by-extended-attributes.1.values.1.name", "activate-protections-by-extended-attributes.1.values.2.name", "activate-protections-by-extended-attributes.1.values.3.name"'
#export csvheader=${csvheader}', "activate-protections-by-extended-attributes.2.name", "activate-protections-by-extended-attributes.2.values.0.name", "activate-protections-by-extended-attributes.2.values.1.name", "activate-protections-by-extended-attributes.2.values.2.name", "activate-protections-by-extended-attributes.2.values.3.name"'
#export csvheader=${csvheader}', "activate-protections-by-extended-attributes.3.name", "activate-protections-by-extended-attributes.3.values.0.name", "activate-protections-by-extended-attributes.3.values.1.name", "activate-protections-by-extended-attributes.3.values.2.name", "activate-protections-by-extended-attributes.3.values.3.name"'
#export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.0.name", "deactivate-protections-by-extended-attributes.0.values.0.name", "deactivate-protections-by-extended-attributes.0.values.1.name", "deactivate-protections-by-extended-attributes.0.values.2.name", "deactivate-protections-by-extended-attributes.0.values.3.name"'
#export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.1.name", "deactivate-protections-by-extended-attributes.1.values.0.name", "deactivate-protections-by-extended-attributes.1.values.1.name", "deactivate-protections-by-extended-attributes.1.values.2.name", "deactivate-protections-by-extended-attributes.1.values.3.name"'
#export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.2.name", "deactivate-protections-by-extended-attributes.2.values.0.name", "deactivate-protections-by-extended-attributes.2.values.1.name", "deactivate-protections-by-extended-attributes.2.values.2.name", "deactivate-protections-by-extended-attributes.2.values.3.name"'
#export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.3.name", "deactivate-protections-by-extended-attributes.3.values.0.name", "deactivate-protections-by-extended-attributes.3.values.1.name", "deactivate-protections-by-extended-attributes.3.values.2.name", "deactivate-protections-by-extended-attributes.3.values.3.name"'
export csvheader=${csvheader}', "use-indicators"'
#export csvheader=${csvheader}', "indicator-overrides.0.action", "indicator-overrides.0.indicator", "indicator-overrides.1.action", "indicator-overrides.1.indicator"'
export csvheader=${csvheader}', "tags.0", "tags.1", "tags.2", "tags.3", "tags.4", "tags.5"'
export csvheader=${csvheader}', "ignore-warnings", "ignore-errors"'

#echo ${csvheader} > ${exportexportfileheader}

echo | tee -a -i ${logfilepath}
#printf "%-${tcol01}s = %s\n" 'X' "${X}" | tee -a -i ${logfilepath}
printf "%-${tcol01}s = %s\n" 'csvheader' "${csvheader}" | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}


#export jsonvaluekeys=''
#export jsonvaluekeys=${jsonvaluekeys}', '

export jsonvaluekeys=''
#export jsonvaluekeys=${jsonvaluekeys}', .["name"]'
export jsonvaluekeys=${jsonvaluekeys}'.["name"], .["color"], .["comments"]'
export jsonvaluekeys=${jsonvaluekeys}', .["active-protections-performance-impact"], .["active-protections-severity"]'
export jsonvaluekeys=${jsonvaluekeys}', .["confidence-level-low"], .["confidence-level-medium"], .["confidence-level-high"]'
export jsonvaluekeys=${jsonvaluekeys}', .["ips"]'
export jsonvaluekeys=${jsonvaluekeys}', .["ips-settings"]["newly-updated-protections"], .["ips-settings"]["exclude-protection-with-performance-impact"], .["ips-settings"]["exclude-protection-with-severity"]'
export jsonvaluekeys=${jsonvaluekeys}', .["malicious-mail-policy-settings"]["email-action"], .["malicious-mail-policy-settings"]["remove-attachments-and-links"], .["malicious-mail-policy-settings"]["malicious-attachments-text"], .["malicious-mail-policy-settings"]["failed-to-scan-attachments-text"], .["malicious-mail-policy-settings"]["malicious-links-text"], .["malicious-mail-policy-settings"]["add-x-header-to-email"]'
export jsonvaluekeys=${jsonvaluekeys}', .["malicious-mail-policy-settings"]["add-email-subject-prefix"], .["malicious-mail-policy-settings"]["email-subject-prefix-text"], .["malicious-mail-policy-settings"]["add-customized-text-to-email-body"], .["malicious-mail-policy-settings"]["email-body-customized-text"], .["malicious-mail-policy-settings"]["send-copy"]'
export jsonvaluekeys=${jsonvaluekeys}', .["scan-malicious-links"]["max-bytes"], .["scan-malicious-links"]["max-links"]'
export jsonvaluekeys=${jsonvaluekeys}', .["threat-emulation"], .["anti-virus"], .["anti-bot"]'
export jsonvaluekeys=${jsonvaluekeys}', .["overrides"][0]["protection"]'
export jsonvaluekeys=${jsonvaluekeys}', .["overrides"][0]["override"]["action"], .["overrides"][0]["override"]["track"], .["overrides"][0]["override"]["capture-packets"]'
export jsonvaluekeys=${jsonvaluekeys}', .["overrides"][1]["protection"]'
export jsonvaluekeys=${jsonvaluekeys}', .["overrides"][1]["override"]["action"], .["overrides"][1]["override"]["track"], .["overrides"][1]["override"]["capture-packets"]'
export jsonvaluekeys=${jsonvaluekeys}', .["use-extended-attributes"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][0]["name"], .["extended-attributes-to-activate"][0]["values"][0]["name"], .["extended-attributes-to-activate"][0]["values"][1]["name"], .["extended-attributes-to-activate"][0]["values"][2]["name"], .["extended-attributes-to-activate"][0]["values"][3]["name"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][1]["name"], .["extended-attributes-to-activate"][1]["values"][0]["name"], .["extended-attributes-to-activate"][1]["values"][1]["name"], .["extended-attributes-to-activate"][1]["values"][2]["name"], .["extended-attributes-to-activate"][1]["values"][3]["name"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][2]["name"], .["extended-attributes-to-activate"][2]["values"][0]["name"], .["extended-attributes-to-activate"][2]["values"][1]["name"], .["extended-attributes-to-activate"][2]["values"][2]["name"], .["extended-attributes-to-activate"][2]["values"][3]["name"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][3]["name"], .["extended-attributes-to-activate"][3]["values"][0]["name"], .["extended-attributes-to-activate"][3]["values"][1]["name"], .["extended-attributes-to-activate"][3]["values"][2]["name"], .["extended-attributes-to-activate"][3]["values"][3]["name"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][0]["name"], .["extended-attributes-to-deactivate"][0]["values"][0]["name"], .["extended-attributes-to-deactivate"][0]["values"][1]["name"], .["extended-attributes-to-deactivate"][0]["values"][2]["name"], .["extended-attributes-to-deactivate"][0]["values"][3]["name"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][1]["name"], .["extended-attributes-to-deactivate"][1]["values"][0]["name"], .["extended-attributes-to-deactivate"][1]["values"][1]["name"], .["extended-attributes-to-deactivate"][1]["values"][2]["name"], .["extended-attributes-to-deactivate"][1]["values"][3]["name"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][2]["name"], .["extended-attributes-to-deactivate"][2]["values"][0]["name"], .["extended-attributes-to-deactivate"][2]["values"][1]["name"], .["extended-attributes-to-deactivate"][2]["values"][2]["name"], .["extended-attributes-to-deactivate"][2]["values"][3]["name"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][3]["name"], .["extended-attributes-to-deactivate"][3]["values"][0]["name"], .["extended-attributes-to-deactivate"][3]["values"][1]["name"], .["extended-attributes-to-deactivate"][3]["values"][2]["name"], .["extended-attributes-to-deactivate"][3]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["use-indicators"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["indicator-overrides"][0]["action"], .["indicator-overrides"][0]["indicator"], .["indicator-overrides"][1]["action"], .["indicator-overrides"][1]["indicator"]'
export jsonvaluekeys=${jsonvaluekeys}', .["tags"][0]["name"], .["tags"][1]["name"], .["tags"][2]["name"], .["tags"][3]["name"], .["tags"][4]["name"], .["tags"][5]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', true, true'

echo | tee -a -i ${logfilepath}
#printf "%-${tcol01}s = %s\n" 'X' "${X}" | tee -a -i ${logfilepath}
printf "%-${tcol01}s = %s\n" 'jsonvaluekeys' "${jsonvaluekeys}" | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}

echo ${csvheader} > ${exportexportfile} 

cat ${showfile} | ${JQ} -r '.profiles[] | [ '"${jsonvaluekeys}"' ] | @csv ' >> ${exportexportfile} 

echo '-------------------------------------------------------------------------------------------------'

#cat ${exportexportfile}


# -------------------------------------------------------------------------------------------------
# Wrap Up
# -------------------------------------------------------------------------------------------------

echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}


echo | tee -a -i ${logfilepath}
echo 'Operations completed!' | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}

echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}

if ${use_showfile} ; then
    ls -alh ${showfilepath}
    echo | tee -a -i ${logfilepath}
    echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
fi

if ${use_exportfile} ; then
    ls -alh ${exportfilepath}
    echo | tee -a -i ${logfilepath}
    echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
fi
if ${use_exportfile4ref} ; then
    ls -alh ${exportfilepath4reference}
    echo | tee -a -i ${logfilepath}
    echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
fi

if ${use_importfile} ; then
    ls -alh ${importfilepath}
    echo | tee -a -i ${logfilepath}
    echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
fi

if ${use_resultsfile} ; then
    ls -alh ${resultsfilepath}
    echo | tee -a -i ${logfilepath}
    echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
fi

echo | tee -a -i ${logfilepath}
echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}
echo 'Log output in file   : '"${logfilepath}" | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}
echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
echo '-------------------------------------------------------------------------------------------------' | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}
echo 'Script completed.' | tee -a -i ${logfilepath}
echo | tee -a -i ${logfilepath}

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
