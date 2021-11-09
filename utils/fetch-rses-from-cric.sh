#!/bin/bash
set -e

CRIC_URL=${CRIC_URL:-https://escape-cric.cern.ch/api/doma/rse/query/?json&preset=doma}
VAR_FILE=${VAR_FILE:-test/variables.yaml}

rse_list=$(curl -s ${CRIC_URL})
keys=($(echo $rse_list | jq .rses | jq keys[]))

for k in "${keys[@]}"; do 
	name=$(echo $rse_list | jq -r .rses.$k.name | tr '[:upper:]' '[:lower:]')
	
	if [[ "${name}" =~ ^.*-tape ]]; then
		>&2 echo "Skipping tape endpoint ${name}";
		continue;
	fi

	protocols=($(echo $rse_list | jq .rses.$k.protocols | jq keys[]))

	for i in "${protocols[@]}"; do
		scheme=$(echo $rse_list | jq -r .rses.$k.protocols[$i].scheme)
		
		if [[ "$scheme" =~ ^(davs|https)$ ]]; then
			desc=$(echo $rse_list | jq -r .rses.$k.protocols[$i].name)
			port=$(echo $rse_list | jq -r .rses.$k.protocols[$i].port)
			prefix=$(echo $rse_list | jq -r .rses.$k.protocols[$i].prefix)
			hostname=$(echo $rse_list | jq -r .rses.$k.protocols[$i].hostname)
			echo "  $name:"
			echo "    enable: true"
			echo "    desc: $desc"
			echo "    type:"
			echo "    endpoint: $scheme://$hostname:$port"
			echo "    paths:"
			echo "      prefix: $prefix"
		else
			>&2 echo "Skipping endpoint ${name} that has scheme ${scheme}"
		fi
	done
done
