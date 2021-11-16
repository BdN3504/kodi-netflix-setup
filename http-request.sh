function generateHttpRequest () {
  method=$1
  endpoint=$2
  contentType=$3
  targetAddress=$4
  targetPort=$5
  payload=$6
  local result=$(cat <<EOF
$method $endpoint HTTP/1.1
Content-Type: $contentType
Accept: */*
Host: $targetAddress:$targetPort
Connection: close
Content-Length: ${#payload}

$payload
EOF
)
  echo "$result"
}

homeWindowJson='{"jsonrpc":"2.0","method":"GUI.ActivateWindow","id":1,"params":{"window":"home"}}'
homeWindowRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$homeWindowJson")

addonWindowJson='{"jsonrpc":"2.0","method":"GUI.ActivateWindow","id":1,"params":{"window":"addonbrowser"}}'
addonWindowRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$addonWindowJson")

openNetflixJson='{"jsonrpc":"2.0","method":"Addons.ExecuteAddon","id":1,"params":{"addonid":"plugin.video.netflix","params":{"command":"activate"}}}'
openNetflixRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$openNetflixJson")

backJson='{"jsonrpc":"2.0","method": "Input.ExecuteAction","id":1,"params": {"action": "back"}}'
backRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$backJson")

rightJson='{"jsonrpc":"2.0","method": "Input.ExecuteAction","id":1,"params": {"action": "right"}}'
rightRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$rightJson")

leftJson='{"jsonrpc":"2.0","method": "Input.ExecuteAction","id":1,"params": {"action": "left"}}'
leftRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$leftJson")

upJson='{"jsonrpc":"2.0","method": "Input.ExecuteAction","id":1,"params": {"action": "up"}}'
upRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$upJson")

downJson='{"jsonrpc":"2.0","method": "Input.ExecuteAction","id":1,"params": {"action": "down"}}'
downRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$downJson")

selectJson='{"jsonrpc":"2.0","method": "Input.ExecuteAction","id":1,"params": {"action": "select"}}'
selectRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$selectJson")

containerFolderNameJson='{"jsonrpc":"2.0","method":"XBMC.GetInfoLabels","id":1,"params":{"labels":["Container.FolderName"]}}'
containerFolderNameRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$containerFolderNameJson")

currentControlJson='{"jsonrpc":"2.0","method":"XBMC.GetInfoLabels","id":1,"params":{"labels":["System.CurrentControl"]}}'
currentControlRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$currentControlJson")

getListItemLabelJson='{"jsonrpc":"2.0","method":"XBMC.GetInfoLabels","id":1,"params":{"labels":["ListItem.Label"]}}'
getListItemLabelRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$getListItemLabelJson")

unknownSourcesJson='{"jsonrpc":"2.0","method": "Settings.SetSettingValue","id":1,"params": {"setting": "addons.unknownsources","value":true}}'
enableUnknownSourcesRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$unknownSourcesJson")

getVersionPropertyJson='{"jsonrpc":"2.0","id":1,"method": "Application.GetProperties", "params": {"properties":["version"]}}'
getVersionPropertyRequest=$(generateHttpRequest "POST" "/jsonrpc" "application/json" "$jsonRpcAddress" "$jsonRpcPort" "$getVersionPropertyJson")
