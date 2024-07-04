#!/bin/bash
telegram_token='7159634730:AAEi5IMJhkV9iWzVLO3bEjz5nPl3ZN-V08k'
telegram_group='-4270399214'
telegram_user_tag="@CabirH2000 @testnetsever"
process_name="humanode-peer"
workspace_file="$HOME/.humanode/workspaces/default/workspace.json"
# Stop editing

# Script starts here
server_ip=$(curl -s https://api.ipify.org)
telegram_bot="https://api.telegram.org/bot${telegram_token}/sendMessage"

# Extract nodename from workspace.json
if [ -f "$workspace_file" ]; then
  nodename=$(jq -r '.nodename' "$workspace_file")
else
  echo "workspace.json file not found"
  exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "jq could not be found, please install it."
  exit 1
fi

# Check the status of the process
if ! pgrep -x "$process_name" > /dev/null; then
  message="🚨Server ${nodename} (${server_ip}) process ${process_name} has been stopped ${telegram_user_tag}"
else
  status_response=$(curl -s http://127.0.0.1:9933 -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"bioauth_status","params":[],"id":1}')

  if [ $? -ne 0 ]; then
    echo "Failed to retrieve status from server"
    exit 1
  fi

  status=$(echo "$status_response" | jq '.result')

  if [ "$(echo "$status" | tr '[:upper:]' '[:lower:]')" == "$(echo '"inactive"' | tr '[:upper:]' '[:lower:]')" ]; then
    message="🚨${nodename} humanode (${server_ip}) is not active, please proceed to do re-authentication ${telegram_user_tag}"
  else
    current_timestamp=$(date +%s)
    expires_at=$(echo "$status_response" | jq '.result.Active.expires_at')
    difference=$(( (expires_at / 1000 - current_timestamp) / 60 ))

    if (( difference > 25 && difference < 31 )); then
      message="🟡${nodename} humanode (${server_ip}) will be deactivated in 30 minutes, please prepare for re-authentication ${telegram_user_tag}"
    elif (( difference > 0 && difference < 6 )); then
      message="🔴${nodename} humanode (${server_ip}) will be deactivated in 5 minutes, please prepare for re-authentication ${telegram_user_tag}"
    else
      message="NULL"
    fi
  fi
fi

# Send message if there is any alert
if [ "$message" != "NULL" ]; then
  curl -X POST -H "Content-Type:multipart/form-data" -F chat_id=${telegram_group} -F text="${message}" ${telegram_bot}
fi
