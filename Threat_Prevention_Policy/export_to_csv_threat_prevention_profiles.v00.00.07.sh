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
# SCRIPT Rough Example for exporting threat prevention profiles
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
#export api_show_command='show threat-rulebase'
#export api_show_command='show threat-rule-exception-rulebase'
export api_show_command='show threat-profiles'

export commandfilename=${api_show_command// /_}
export commandfilename=${commandfilename//-/_}

export showfileprefix=z.${commandfilename}
export showfileext=json
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
# Show what was selected and names of things
# -------------------------------------------------------------------------------------------------


echo


# -------------------------------------------------------------------------------------------------
# Generate working json file of API output for future processing
# -------------------------------------------------------------------------------------------------


echo 'Generate working json file of API output for future processing...'

#export detaillevelset=standard
export detaillevelset=full
#export showfile=${showfileprefix}.${layerfilename}.${detaillevelset}.${localnamenow}.${showfileext}
export showfile=${showfileprefix}.${detaillevelset}.${localnamenow}.${showfileext}

echo
#echo 'showfile           = '"${showfile}"
#echo 'showfile : standard = '"${showfile}"
echo 'showfile : full     = '"${showfile}"
echo

export MgmtCLI_Base_OpParms='-f json'
export MgmtCLI_Show_OpParms='details-level full '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='details-level standard '${MgmtCLI_Base_OpParms}
#export MgmtCLI_Show_OpParms='use-object-dictionary false '${MgmtCLI_Base_OpParms}
export MgmtCLI_Show_OpParms='limit 100 offset 0 '${MgmtCLI_Show_OpParms}

#mgmt_cli -r true --port ${apisslport} show threat-profiles limit 25 offset 0 details-level full --format json > "${showfile}"
mgmt_cli ${MgmtCLI_Authentication} ${api_show_command} ${MgmtCLI_Show_OpParms} > "${showfile}"

echo '-------------------------------------------------------------------------------------------------'

ls -alh ${showfile}

echo '-------------------------------------------------------------------------------------------------'


# -------------------------------------------------------------------------------------------------
# Generate Threat Prevention Profiles detailed export for reference
# -------------------------------------------------------------------------------------------------


echo 'Generate Threat Prevention Profiles detailed export for reference'
echo

export outfileheader=${outfileprefix}.FOR_REFERENCE_ONLY.header.${outfileext}


#export csvheader=''
#export csvheader=${csvheader}', '

export csvheader=''
#export csvheader=${csvheader}', "name"'
export csvheader=${csvheader}'"name", "color", "comments"'
export csvheader=${csvheader}', "type"'
export csvheader=${csvheader}', "active-protections-performance-impact", "active-protections-severity"'
export csvheader=${csvheader}', "confidence-level-low", "confidence-level-medium", "confidence-level-high"'
export csvheader=${csvheader}', "ips"'
export csvheader=${csvheader}', "ips-settings.newly-updated-protections", "ips-settings.exclude-protection-with-performance-impact", "ips-settings.exclude-protection-with-severity"'
export csvheader=${csvheader}', "malicious-mail-policy-settings.email-action", "malicious-mail-policy-settings.remove-attachments-and-links", "malicious-mail-policy-settings.malicious-attachments-text", "malicious-mail-policy-settings.failed-to-scan-attachments-text", "malicious-mail-policy-settings.malicious-links-text", "malicious-mail-policy-settings.add-x-header-to-email"'
export csvheader=${csvheader}', "malicious-mail-policy-settings.add-email-subject-prefix", "malicious-mail-policy-settings.email-subject-prefix-text", "malicious-mail-policy-settings.add-customized-text-to-email-body", "malicious-mail-policy-settings.email-body-customized-text", "malicious-mail-policy-settings.send-copy"'
export csvheader=${csvheader}', "scan-malicious-links.max-bytes", "scan-malicious-links.max-links"'
export csvheader=${csvheader}', "threat-emulation", "anti-virus", "anti-bot"'
export csvheader=${csvheader}', "overrides.0.protection", "overrides.0.protection-uid", "overrides.0.action", "overrides.0.track", "overrides.0.capture-packets"'
export csvheader=${csvheader}', "overrides.1.protection", "overrides.1.protection-uid", "overrides.1.action", "overrides.1.track", "overrides.1.capture-packets"'
export csvheader=${csvheader}', "use-extended-attributes"'
export csvheader=${csvheader}', "extended-attributes-to-activate.0.name", "extended-attributes-to-activate.0.values.0.name", "extended-attributes-to-activate.0.values.1.name", "extended-attributes-to-activate.0.values.2.name", "extended-attributes-to-activate.0.values.3.name"'
export csvheader=${csvheader}', "extended-attributes-to-activate.1.name", "extended-attributes-to-activate.1.values.0.name", "extended-attributes-to-activate.1.values.1.name", "extended-attributes-to-activate.1.values.2.name", "extended-attributes-to-activate.1.values.3.name"'
export csvheader=${csvheader}', "extended-attributes-to-activate.2.name", "extended-attributes-to-activate.2.values.0.name", "extended-attributes-to-activate.2.values.1.name", "extended-attributes-to-activate.2.values.2.name", "extended-attributes-to-activate.2.values.3.name"'
export csvheader=${csvheader}', "extended-attributes-to-activate.3.name", "extended-attributes-to-activate.3.values.0.name", "extended-attributes-to-activate.3.values.1.name", "extended-attributes-to-activate.3.values.2.name", "extended-attributes-to-activate.3.values.3.name"'
export csvheader=${csvheader}', "extended-attributes-to-deactivate.0.name", "extended-attributes-to-deactivate.0.values.0.name", "extended-attributes-to-deactivate.0.values.1.name", "extended-attributes-to-deactivate.0.values.2.name", "extended-attributes-to-deactivate.0.values.3.name"'
export csvheader=${csvheader}', "extended-attributes-to-deactivate.1.name", "extended-attributes-to-deactivate.1.values.0.name", "extended-attributes-to-deactivate.1.values.1.name", "extended-attributes-to-deactivate.1.values.2.name", "extended-attributes-to-deactivate.1.values.3.name"'
export csvheader=${csvheader}', "extended-attributes-to-deactivate.2.name", "extended-attributes-to-deactivate.2.values.0.name", "extended-attributes-to-deactivate.2.values.1.name", "extended-attributes-to-deactivate.2.values.2.name", "extended-attributes-to-deactivate.2.values.3.name"'
export csvheader=${csvheader}', "extended-attributes-to-deactivate.3.name", "extended-attributes-to-deactivate.3.values.0.name", "extended-attributes-to-deactivate.3.values.1.name", "extended-attributes-to-deactivate.3.values.2.name", "extended-attributes-to-deactivate.3.values.3.name"'
export csvheader=${csvheader}', "use-indicators"'
#export csvheader=${csvheader}', "indicator-overrides.0.action", "indicator-overrides.0.indicator", "indicator-overrides.1.action", "indicator-overrides.1.indicator"'
export csvheader=${csvheader}', "tags.0", "tags.1", "tags.2", "tags.3", "tags.4", "tags.5"'
export csvheader=${csvheader}', "meta-info.validation-state", "meta-info.last-modifier", "meta-info.creator"'

echo ${csvheader} > ${outfileheader}

echo
echo 'csvheader     = '${csvheader} 
echo


#export jsonvaluekeys=''
#export jsonvaluekeys=${jsonvaluekeys}', '

export jsonvaluekeys=''
#export jsonvaluekeys=${jsonvaluekeys}', .["name"]'
export jsonvaluekeys=${jsonvaluekeys}'.["name"], .["color"], .["comments"]'
export jsonvaluekeys=${jsonvaluekeys}', .["type"]'
export jsonvaluekeys=${jsonvaluekeys}', .["active-protections-performance-impact"], .["active-protections-severity"]'
export jsonvaluekeys=${jsonvaluekeys}', .["confidence-level-low"], .["confidence-level-medium"], .["confidence-level-high"]'
export jsonvaluekeys=${jsonvaluekeys}', .["ips"]'
export jsonvaluekeys=${jsonvaluekeys}', .["ips-settings"]["newly-updated-protections"], .["ips-settings"]["exclude-protection-with-performance-impact"], .["ips-settings"]["exclude-protection-with-severity"]'
export jsonvaluekeys=${jsonvaluekeys}', .["malicious-mail-policy-settings"]["email-action"], .["malicious-mail-policy-settings"]["remove-attachments-and-links"], .["malicious-mail-policy-settings"]["malicious-attachments-text"], .["malicious-mail-policy-settings"]["failed-to-scan-attachments-text"], .["malicious-mail-policy-settings"]["malicious-links-text"], .["malicious-mail-policy-settings"]["add-x-header-to-email"]'
export jsonvaluekeys=${jsonvaluekeys}', .["malicious-mail-policy-settings"]["add-email-subject-prefix"], .["malicious-mail-policy-settings"]["email-subject-prefix-text"], .["malicious-mail-policy-settings"]["add-customized-text-to-email-body"], .["malicious-mail-policy-settings"]["email-body-customized-text"], .["malicious-mail-policy-settings"]["send-copy"]'
export jsonvaluekeys=${jsonvaluekeys}', .["scan-malicious-links"]["max-bytes"], .["scan-malicious-links"]["max-links"]'
export jsonvaluekeys=${jsonvaluekeys}', .["threat-emulation"], .["anti-virus"], .["anti-bot"]'
export jsonvaluekeys=${jsonvaluekeys}', .["overrides"][0]["protection"], .["overrides"][0]["protection-uid"], .["overrides"][0]["override"]["action"], .["overrides"][0]["override"]["track"], .["overrides"][0]["override"]["capture-packets"]'
export jsonvaluekeys=${jsonvaluekeys}', .["overrides"][1]["protection"], .["overrides"][1]["protection-uid"], .["overrides"][1]["override"]["action"], .["overrides"][1]["override"]["track"], .["overrides"][1]["override"]["capture-packets"]'
export jsonvaluekeys=${jsonvaluekeys}', .["use-extended-attributes"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][0]["name"], .["extended-attributes-to-activate"][0]["values"][0]["name"], .["extended-attributes-to-activate"][0]["values"][1]["name"], .["extended-attributes-to-activate"][0]["values"][2]["name"], .["extended-attributes-to-activate"][0]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][1]["name"], .["extended-attributes-to-activate"][1]["values"][0]["name"], .["extended-attributes-to-activate"][1]["values"][1]["name"], .["extended-attributes-to-activate"][1]["values"][2]["name"], .["extended-attributes-to-activate"][1]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][2]["name"], .["extended-attributes-to-activate"][2]["values"][0]["name"], .["extended-attributes-to-activate"][2]["values"][1]["name"], .["extended-attributes-to-activate"][2]["values"][2]["name"], .["extended-attributes-to-activate"][2]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][3]["name"], .["extended-attributes-to-activate"][3]["values"][0]["name"], .["extended-attributes-to-activate"][3]["values"][1]["name"], .["extended-attributes-to-activate"][3]["values"][2]["name"], .["extended-attributes-to-activate"][3]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][0]["name"], .["extended-attributes-to-deactivate"][0]["values"][0]["name"], .["extended-attributes-to-deactivate"][0]["values"][1]["name"], .["extended-attributes-to-deactivate"][0]["values"][2]["name"], .["extended-attributes-to-deactivate"][0]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][1]["name"], .["extended-attributes-to-deactivate"][1]["values"][0]["name"], .["extended-attributes-to-deactivate"][1]["values"][1]["name"], .["extended-attributes-to-deactivate"][1]["values"][2]["name"], .["extended-attributes-to-deactivate"][1]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][2]["name"], .["extended-attributes-to-deactivate"][2]["values"][0]["name"], .["extended-attributes-to-deactivate"][2]["values"][1]["name"], .["extended-attributes-to-deactivate"][2]["values"][2]["name"], .["extended-attributes-to-deactivate"][2]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][3]["name"], .["extended-attributes-to-deactivate"][3]["values"][0]["name"], .["extended-attributes-to-deactivate"][3]["values"][1]["name"], .["extended-attributes-to-deactivate"][3]["values"][2]["name"], .["extended-attributes-to-deactivate"][3]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["use-indicators"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["indicator-overrides"][0]["action"], .["indicator-overrides"][0]["indicator"], .["indicator-overrides"][1]["action"], .["indicator-overrides"][1]["indicator"]'
export jsonvaluekeys=${jsonvaluekeys}', .["tags"][0]["name"], .["tags"][1]["name"], .["tags"][2]["name"], .["tags"][3]["name"], .["tags"][4]["name"], .["tags"][5]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["meta-info"]["validation-state"], .["meta-info"]["last-modifier"], .["meta-info"]["creator"]'

echo
echo 'jsonvaluekeys = '${jsonvaluekeys} 
echo

export outfile=${outfileprefix}.${localnamenow}.${outfileext}

cat ${outfileheader} > ${outfile} 

cat ${showfile} | ${JQ} -r '.profiles[] | [ '"${jsonvaluekeys}"' ] | @csv ' >> ${outfile} 

echo '-------------------------------------------------------------------------------------------------'

#cat ${outfile}


# -------------------------------------------------------------------------------------------------
# Generate Threat Prevention Profiles detailed export for actual import
# -------------------------------------------------------------------------------------------------


echo 'Generate Threat Prevention Profiles detailed export for actual import'
echo

export exportoutfileheader=${outfileprefix}.export.header.${outfileext}


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
export csvheader=${csvheader}', "activate-protections-by-extended-attributes.0.name", "activate-protections-by-extended-attributes.0.values.0.name", "activate-protections-by-extended-attributes.0.values.1.name", "activate-protections-by-extended-attributes.0.values.2.name", "activate-protections-by-extended-attributes.0.values.3.name"'
export csvheader=${csvheader}', "activate-protections-by-extended-attributes.1.name", "activate-protections-by-extended-attributes.1.values.0.name", "activate-protections-by-extended-attributes.1.values.1.name", "activate-protections-by-extended-attributes.1.values.2.name", "activate-protections-by-extended-attributes.1.values.3.name"'
export csvheader=${csvheader}', "activate-protections-by-extended-attributes.2.name", "activate-protections-by-extended-attributes.2.values.0.name", "activate-protections-by-extended-attributes.2.values.1.name", "activate-protections-by-extended-attributes.2.values.2.name", "activate-protections-by-extended-attributes.2.values.3.name"'
export csvheader=${csvheader}', "activate-protections-by-extended-attributes.3.name", "activate-protections-by-extended-attributes.3.values.0.name", "activate-protections-by-extended-attributes.3.values.1.name", "activate-protections-by-extended-attributes.3.values.2.name", "activate-protections-by-extended-attributes.3.values.3.name"'
export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.0.name", "deactivate-protections-by-extended-attributes.0.values.0.name", "deactivate-protections-by-extended-attributes.0.values.1.name", "deactivate-protections-by-extended-attributes.0.values.2.name", "deactivate-protections-by-extended-attributes.0.values.3.name"'
export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.1.name", "deactivate-protections-by-extended-attributes.1.values.0.name", "deactivate-protections-by-extended-attributes.1.values.1.name", "deactivate-protections-by-extended-attributes.1.values.2.name", "deactivate-protections-by-extended-attributes.1.values.3.name"'
export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.2.name", "deactivate-protections-by-extended-attributes.2.values.0.name", "deactivate-protections-by-extended-attributes.2.values.1.name", "deactivate-protections-by-extended-attributes.2.values.2.name", "deactivate-protections-by-extended-attributes.2.values.3.name"'
export csvheader=${csvheader}', "deactivate-protections-by-extended-attributes.3.name", "deactivate-protections-by-extended-attributes.3.values.0.name", "deactivate-protections-by-extended-attributes.3.values.1.name", "deactivate-protections-by-extended-attributes.3.values.2.name", "deactivate-protections-by-extended-attributes.3.values.3.name"'
export csvheader=${csvheader}', "use-indicators"'
#export csvheader=${csvheader}', "indicator-overrides.0.action", "indicator-overrides.0.indicator", "indicator-overrides.1.action", "indicator-overrides.1.indicator"'
export csvheader=${csvheader}', "tags.0", "tags.1", "tags.2", "tags.3", "tags.4", "tags.5"'
export csvheader=${csvheader}', "ignore-warnings", "ignore-errors"'

echo ${csvheader} > ${exportoutfileheader}

echo
echo 'csvheader     = '${csvheader} 
echo


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
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][0]["name"], .["extended-attributes-to-activate"][0]["values"][0]["name"], .["extended-attributes-to-activate"][0]["values"][1]["name"], .["extended-attributes-to-activate"][0]["values"][2]["name"], .["extended-attributes-to-activate"][0]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][1]["name"], .["extended-attributes-to-activate"][1]["values"][0]["name"], .["extended-attributes-to-activate"][1]["values"][1]["name"], .["extended-attributes-to-activate"][1]["values"][2]["name"], .["extended-attributes-to-activate"][1]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][2]["name"], .["extended-attributes-to-activate"][2]["values"][0]["name"], .["extended-attributes-to-activate"][2]["values"][1]["name"], .["extended-attributes-to-activate"][2]["values"][2]["name"], .["extended-attributes-to-activate"][2]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-activate"][3]["name"], .["extended-attributes-to-activate"][3]["values"][0]["name"], .["extended-attributes-to-activate"][3]["values"][1]["name"], .["extended-attributes-to-activate"][3]["values"][2]["name"], .["extended-attributes-to-activate"][3]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][0]["name"], .["extended-attributes-to-deactivate"][0]["values"][0]["name"], .["extended-attributes-to-deactivate"][0]["values"][1]["name"], .["extended-attributes-to-deactivate"][0]["values"][2]["name"], .["extended-attributes-to-deactivate"][0]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][1]["name"], .["extended-attributes-to-deactivate"][1]["values"][0]["name"], .["extended-attributes-to-deactivate"][1]["values"][1]["name"], .["extended-attributes-to-deactivate"][1]["values"][2]["name"], .["extended-attributes-to-deactivate"][1]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][2]["name"], .["extended-attributes-to-deactivate"][2]["values"][0]["name"], .["extended-attributes-to-deactivate"][2]["values"][1]["name"], .["extended-attributes-to-deactivate"][2]["values"][2]["name"], .["extended-attributes-to-deactivate"][2]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["extended-attributes-to-deactivate"][3]["name"], .["extended-attributes-to-deactivate"][3]["values"][0]["name"], .["extended-attributes-to-deactivate"][3]["values"][1]["name"], .["extended-attributes-to-deactivate"][3]["values"][2]["name"], .["extended-attributes-to-deactivate"][3]["values"][3]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', .["use-indicators"]'
#export jsonvaluekeys=${jsonvaluekeys}', .["indicator-overrides"][0]["action"], .["indicator-overrides"][0]["indicator"], .["indicator-overrides"][1]["action"], .["indicator-overrides"][1]["indicator"]'
export jsonvaluekeys=${jsonvaluekeys}', .["tags"][0]["name"], .["tags"][1]["name"], .["tags"][2]["name"], .["tags"][3]["name"], .["tags"][4]["name"], .["tags"][5]["name"]'
export jsonvaluekeys=${jsonvaluekeys}', true, true'

echo
echo 'jsonvaluekeys = '${jsonvaluekeys} 
echo

export exportoutfile=${outfileprefix}.export.${localnamenow}.${outfileext}

cat ${exportoutfileheader} > ${exportoutfile} 

cat ${showfile} | ${JQ} -r '.profiles[] | [ '"${jsonvaluekeys}"' ] | @csv ' >> ${exportoutfile} 

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

