source kodi-variables.sh
source http-request.sh

installFromZipFile="Install from zip file"
installFromRepository="Install from repository"
castagnaITAddonRepositoryPattern="^CastagnaIT Repository for Kodi.*$"
additionalAddonsPattern="^The following additional add-ons will be installed.*$"
homeFolder="Home folder"
videoAddons="Video add-ons"
netflix="Netflix"
downloadsFolder="Downloads"
addonBrowserWindow="Add-on browser"
installPattern="^Install.*$"
ok="OK"
warning="Warning!"
no="No"
yes="Yes"
cancel="Cancel"

dpkg -s ncat &> /dev/null
ncatInstalled=$?
if [ $ncatInstalled -ne 0 ]
then
  sudo apt -yq install ncat
fi

dpkg -s jq &> /dev/null
jqInstalled=$?
if [ $jqInstalled -ne 0 ]
then
  sudo apt -yq install jq
fi

dpkg -s curl &> /dev/null
curlInstalled=$?
if [ $curlInstalled -ne 0 ]
then
  sudo apt -yq install curl
fi

pingResult=$(curl --silent -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$pingJson" | jq -r ".result")
if [ "pong" != "$pingResult" ]
then
  echo "No jsonRpcServer is running on $jsonRpcAddress:$jsonRpcPort"
  enableInAdvancedSettings=yes
  read -r -e -i "$enableInAdvancedSettings" -p "Shall the jsonRpcServer be enabled in the advancedsettings.xml file?" enableInAdvancedSettingsInput
  enableInAdvancedSettings=${enableInAdvancedSettingsInput:-$enableInAdvancedSettings}
  if [ "yes" = "$enableInAdvancedSettings" ]
  then
    mkdir -p "$kodiHome"/userdata
    cat >"$kodiHome"/userdata/advancedsettings.xml <<EOL
<advancedsettings version="1.0">
   <services>
       <esallinterfaces>true</esallinterfaces>
       <webserver>true</webserver>
       <zeroconf>true</zeroconf>
       <tcpport>$jsonRpcPort</tcpport>
   </services>
</advancedsettings>
EOL
    while [ "pong" != "$pingResult" ]
    do
      echo "You need to start kodi now and enable the json rpc server."
      read -r -u 1 waitingForKodiToStart
      pingResult=$(curl --silent -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$pingJson" | jq -r ".result")
      if [ "pong" != "$pingResult" ]
      then
        echo "No jsonRpcServer is running on $jsonRpcAddress:$jsonRpcPort"
      fi
    done
  fi
fi

majorVersion=$(curl --silent -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getVersionPropertyJson" | jq ".result.version.major")

if [ $majorVersion -eq 18 ]
then
  castagnaitRepositoryFileName=repository.castagnait-1.0.1.zip
  if [ ! -f "$downloadDir"/$castagnaitRepositoryFileName ]
  then
    wget https://github.com/castagnait/repository.castagnait/raw/master/repository.castagnait-1.0.1.zip -P "$downloadDir"
  fi
  sudo apt -yq install build-essential python-pip libnss3 kodi-inputstream-adaptive
  sudo pip install pycryptodomex
  version="Version 1.12.7"
elif [ $majorVersion -eq 19 ]
then
  castagnaitRepositoryFileName=repository.castagnait-1.0.0.zip
  if [ ! -f "$downloadDir"/$castagnaitRepositoryFileName ]
  then
    wget https://github.com/castagnait/repository.castagnait/raw/matrix/repository.castagnait-1.0.0.zip -P "$downloadDir"
  fi
  sudo apt -yq install build-essential python3-pip libnss3 kodi-inputstream-adaptive
  sudo pip3 install pycryptodomex
  version="Version 1.18.0"
else
  echo "Could not determine kodi version, check if jsonrpc interface is active." && exit
fi

echo "$enableUnknownSourcesRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

echo "$leftRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

echo "$addonWindowRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

currentFolder=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$containerFolderNameJson" | jq -r '.result."Container.FolderName"' )

while [ "$currentFolder" != "$addonBrowserWindow" ]
do
  echo "$backRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  currentFolder=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$containerFolderNameJson" | jq -r '.result."Container.FolderName"' )
done

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [ "$label" != "$installFromZipFile" ]
do
  echo "$downRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

if [ $majorVersion -eq 19 ]
then
  dialogTitle=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentDialogTitleJson" | jq -r '.result."Control.GetLabel(1)"' )
  if [ "$dialogTitle" == "$warning" ]
  then
    currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
    echo "Current control is $currentControl."
    while [ "$currentControl" = "$no" ]
    do
      echo "$leftRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
      currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
      sleep 1
    done

    echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  fi
fi

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [ "$label" != "$homeFolder" ]
do
  echo "$downRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [ "$label" != "$downloadsFolder" ]
do
  echo "$downRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [ "$label" != "$castagnaitRepositoryFileName" ]
do
  echo "$downRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

echo "$addonWindowRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

currentFolder=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$containerFolderNameJson" | jq -r '.result."Container.FolderName"' )

while [ "$currentFolder" != "$addonBrowserWindow" ]
do
  echo "$backRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  currentFolder=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$containerFolderNameJson" | jq -r '.result."Container.FolderName"' )
done

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [ "$label" != "$installFromRepository" ]
do
  echo "$downRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [[ ! "$label" =~ $castagnaITAddonRepositoryPattern ]]
do
  echo "$downRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [ "$label" != "$videoAddons" ]
do
  echo "$downRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
while [ "$label" != "$netflix" ]
do
  echo "$upRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  label=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$getListItemLabelJson" | jq -r '.result."ListItem.Label"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
while [[ ! "$currentControl" =~ $installPattern ]]
do
  echo "$rightRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

sleep 1
dialogTitle=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentDialogTitleJson" | jq -r '.result."Control.GetLabel(1)"' )
echo "DialogTitle is $dialogTitle."
read -r -u 1 watingForUserInput
if [[ "$dialogTitle" =~ $additionalAddonsPattern ]]
then
  currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
  echo "Current control is $currentControl."
  while [ "$currentControl" = "$Cancel" ]
  do
    echo "$upRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
    currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
    echo "Current control inside while loop is $currentControl."
    read -r -u 1 watingForUserInput
    sleep 1
  done

  echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
fi

currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
while [ "$currentControl" != "$version" ]
do
  echo "$upRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

sleep 1
echo "$rightRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

echo "$rightRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
while [ "$currentControl" != "$ok" ]
do
  echo "$upRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only
  currentControl=$(curl -s -X POST -H 'Content-Type: application/json' http://"$jsonRpcAddress":"$jsonRpcPort"/jsonrpc --data "$currentControlJson" | jq -r '.result."System.CurrentControl"' )
  sleep 1
done

echo "$selectRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

echo "$homeWindowRequest" | ncat "$jsonRpcAddress" "$jsonRpcPort" --send-only

if [ $ncatInstalled -ne 0 ]
then
  sudo apt -yq purge ncat
fi

if [ $jqInstalled -ne 0 ]
then
  sudo apt -yq purge jq
fi

if [ $curlInstalled -ne 0 ]
then
  sudo apt -yq purge curl
fi
