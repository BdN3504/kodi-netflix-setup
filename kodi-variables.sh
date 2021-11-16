variablesScript=$(basename "$0")

kodiHome=~/.kodi
downloadDir=~/Downloads
jsonRpcPort=8080
jsonRpcAddress=localhost

if [ "$variablesScript" == "kodi-variables.sh" ]
then

  read -e -i "$kodiHome" -p "Provide kodi home path: " kodiHomeInput
  kodiHome=${kodiHomeInput:-$kodiHome}
  sed -i -E "s|^(kodiHome=)/.*$|\1$kodiHome|g" "$variablesScript"

  read -e -i "$downloadDir" -p "Provide the Downloads directoy location: " downloadDirInput
  downloadDir=${downloadDirInput:-$downloadDir}
  sed -i -E "s|^(downloadDir=)/.*$|\1$downloadDir|g" "$variablesScript"

  read -e -i "$jsonRpcPort" -p "Define the tcp port the jsonRpc server should listen on: " jsonRpcPortInput
  jsonRpcPort=${jsonRpcPortInput:-$jsonRpcPort}
  sed -i -E "s|^(jsonRpcPort=)[0-9]*$|\1$jsonRpcPort|g" "$variablesScript"

  read -e -i "$jsonRpcAddress" -p "Define the address the jsonRpc server will listen on: " jsonRpcAddressInput
  jsonRpcAddress=${jsonRpcAddressInput:-$jsonRpcAddress}
  sed -i -E "s%^(jsonRpcAddress=).*$%\1$jsonRpcAddress%g" "$variablesScript"

fi
