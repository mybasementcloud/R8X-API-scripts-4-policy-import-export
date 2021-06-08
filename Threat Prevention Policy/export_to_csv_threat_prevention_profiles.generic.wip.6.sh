#!/bin/bash
#

# mgmt_cli -r true show threat-profiles limit 25 offset 0 details-level full --format json > z.show.threat-profiles.full.`vnamenow`.json
# mgmt_cli -r true show threat-profiles limit 25 offset 0 details-level standard --format json > z.show.threat-profiles.standard.`vnamenow`.json


export localnamenow=${HOSTNAME}.`date +%Y-%m-%d-%H%M%S%Z`

pythonpath=${MDS_FWDIR}/Python/bin/
get_api_local_port=`${pythonpath}/python ${MDS_FWDIR}/scripts/api_get_port.py -f json | ${JQ} '. | .external_port'`
api_local_port=${get_api_local_port//\"/}
export apisslport=${api_local_port}

export showfileprefix='show_threat_profiles'
export outfileprefix='test_threat_profiles'
export outfileext=csv

export showfile=${showfileprefix}.full.${localnamenow}.json

echo
echo 'showfile      = '"${showfile}"
echo

mgmt_cli -r true --port ${apisslport} show threat-profiles limit 25 offset 0 details-level full --format json > "${showfile}"

export outfileheader=${outfileprefix}.header.${outfileext}


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

echo

#cat ${outfile}

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

echo

#cat ${exportoutfile}

echo

ls -alh *.json
ls -alh *.csv

