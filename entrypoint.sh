#!/usr/bin/env bash

function get_jira_ticket() {
    issueKey="$1"
    curl -D- -u $JIRA_USER:$JIRA_PASSWORD -H "Accept: application/json" "$JIRA_BASE_URL/rest/api/2/issue/picker?query=$issueKey" -o findjirakey.json
}

function set_issue_key_if_exist() {
    issueKey="$1"
    key=$(cat findjirakey.json | jq -c '.sections[0].issues[0].key')
    if [ "$key" != null ]; then
        echo "Jira key found: $issueKey"
        echo "::set-output name=issue::$issueKey"
        exit
    fi
}


if [[ $MESSAGE =~ [a-zA-Z0-9]+-[0-9]+ ]]; then
   keys=$(echo $MESSAGE | grep -P '[a-zA-Z0-9]+-[0-9]+' -o)
   while IFS='/| ' read -ra KEYS; do
     for issueKey in "${KEYS[@]}"; do
       echo "Run search for: $issueKey"
       get_jira_ticket "$issueKey"
       set_issue_key_if_exist "$issueKey"
     done
   done <<< "$keys"
 fi
