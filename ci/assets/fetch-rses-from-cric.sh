#!/bin/bash

CRIC_URL=${CRIC_URL:-https://escape-cric.cern.ch/api/doma/rse/query/?json&preset=doma}
VAR_FILE=${VAR_FILE:-test/variables.yaml}

rse_list=$(curl -s ${CRIC_URL})
keys=($(echo $rse_list | jq .rses | jq keys[]))

ec=0

for k in "${keys[@]}"; do 
	typeset -l name=$(echo $rse_list | jq -r .rses.$k.name)
	
	cat ${VAR_FILE} | shyaml keys endpoints.$name > /dev/null 2>&1

	if [ $? -ne 0 ]; then
		desc=$(echo $rse_list | jq -r .rses.$k.protocols[0].name)
		hostname=$(echo $rse_list | jq -r .rses.$k.protocols[0].hostname)
		scheme=$(echo $rse_list | jq -r .rses.$k.protocols[0].scheme)
		port=$(echo $rse_list | jq -r .rses.$k.protocols[0].port)
		prefix=$(echo $rse_list | jq -r .rses.$k.protocols[0].prefix)
	
		if [[ "$scheme" =~ ^(davs|https)$ ]]; then
			echo "  $name:"
			echo "    enable: true"
			echo "    desc: $desc"
			echo "    type:"
			echo "    endpoint: $scheme://$hostname:$port"
			echo "    paths:"
			echo "      prefix: $prefix"
			
			(( ec++ ))
		fi
	fi
done

exit ${ec}