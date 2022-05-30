#!/usr/bin/env bash

while getopts u:p:j:m: flag
do
    case "${flag}" in
        u) user=${OPTARG};;
        p) password=${OPTARG};;
        j) jira_base_url=${OPTARG};;
        m) message=${OPTARG};;
    esac
done

if [[ "$message" =~ [a-zA-Z0-9]+-[0-9]+ ]]; then
   keys=$(echo "$message" | grep -P '[a-zA-Z0-9]+-[0-9]+' -o)
   while IFS='/| ' read -ra KEYS; do
     for issueKey in "${KEYS[@]}"; do
       echo "Run search for: $issueKey"
       curl -D- -u "$user":"$password" -H "Content-Type: application/json" "$jira_base_url/rest/api/2/issue/picker?query=$issueKey" -o findjirakey.json             
       key=$(cat findjirakey.json | jq -c '.sections[0].issues[0].key')
       if [ "$key" != null ]; then
           echo "Jira key found: $issueKey"
           echo "::set-output name=issue::$issueKey"
           exit
       fi
     done
   done <<< "$keys"
 fi
