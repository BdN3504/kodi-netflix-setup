# Setup Netflix on kodi automatically

This repository contains a collection of shell scripts that enable you to automate the installation of netflix on kodi.
Kodi versions 18 and 19 are supported. The scripts rely heavily on the jsonrpc interface, it must be enabled before
using the scripts. 

The script will download and install the [castagnaIT repository](https://github.com/CastagnaIT/repository.castagnait) for the correct version of kodi. After the installation
of the repository, the plugin is going to get installed.

### Configuration
The configuration of paths and the jsonrpc server address and port are stored in the [kodi-variables](kodi-variables.sh) script. You can 
execute that script to alter the values.

```bash kodi-variables.sh```

### Running the script
After the configuration has been set up, just run the [kodi-install-netflix-plugin](kodi-install-netflix-plugin.sh) script with bash.

```bash kodi-install-netflix-plugin.sh```
