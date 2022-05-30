#!/usr/bin/env bash

set -eu

# while getopts u:p:j:m: flag
# do
#     case "${flag}" in
#         u) user=${OPTARG};;
#         p) password=${OPTARG};;
#         j) jira_base_url=${OPTARG};;
#         m) message=${OPTARG};;
#     esac
# done

# set user="$1"
# set password="$2"
# set jira_base_url="$3"
# set message="$4"

if [[ $MESSAGE =~ [a-zA-Z0-9]+-[0-9]+ ]]; then
   keys=$(echo $MESSAGE | grep -P '[a-zA-Z0-9]+-[0-9]+' -o)
   while IFS='/| ' read -ra KEYS; do
     for issueKey in "${KEYS[@]}"; do
       echo "Run search for: $issueKey"
       curl -D- -u $JIRA_USER:$JIRA_PASSWORD -H "Content-Type: application/json" "$JIRA_BASE_URL/rest/api/2/issue/picker?query=$issueKey" -o findjirakey.json             
       key=$(cat findjirakey.json | jq -c '.sections[0].issues[0].key')
       if [ "$key" != null ]; then
           echo "Jira key found: $issueKey"
           echo "::set-output name=issue::$issueKey"
           exit
       fi
     done
   done <<< "$keys"
 fi
