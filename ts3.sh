#!/bin/bash

apt-get update
apt-get upgrade
apt-get install sudo tar wget

TS3_DIR="/opt/ts3server"
TS3_VER="3.12.1"

set -e

X86="https://files.teamspeak-services.com/releases/server/$TS3_VER/teamspeak3-server_linux_x86-$TS3_VER.tar.bz2"
X64="https://files.teamspeak-services.com/releases/server/$TS3_VER/teamspeak3-server_linux_amd64-$TS3_VER.tar.bz2"

A=$(arch)
if [ "$A" = "x86_64" ]; then
  URL="$X64"
elif [ "$A" = "i386" ]; then
  URL="$X86"
elif [ "$A" = "i686" ]; then
  URL="$X86"
fi

function install_ts3-server {
mkdir -p "$TS3_DIR"
touch "$TS3_DIR"/.ts3server_license_accepted
tar -xjf teamspeak3-server_linux*.tar.bz2
mv teamspeak3-server_linux*/* "$TS3_DIR"
rm -rf *.bz2
}

if wget -q "$URL"; then
  install_ts3-server
else
  echo -e "\nDogodila se greska.!\n"
  exit 1
fi

touch "$TS3_DIR"/ts3server.ini
cat > "$TS3_DIR"/ts3server.ini <<EOF
#Folder od *.ini fajla za koriscenje.
inifile=ts3server.ini
# Voice IP na kome se nalazi Virtuelni Server. [UDP] (Default: 0.0.0.0)
voice_ip=0.0.0.0
# Query IP gde se nalazi Instanca. [TCP] (Default: 0.0.0.0)
query_ip=0.0.0.0
# Filetransfer IP gde se nalazi Instanca. [TCP] (Default: 0.0.0.0)
filetransfer_ip=
# Voice PORT na kome se nalazi Server. [UDP] (Default: 9987)
default_voice_port=9987
# Query PORT Servera. [TCP] (Default: 10011)
query_port=10011
# Filetransfer port gde se nalazi Instanca. [TCP] (Default: 30033)
filetransfer_port=30033
# Koristi isti log fajl
logappend=1
EOF

echo "Startovanje Team Speak 3 Servera..."
systemctl --quiet enable ts3server.service
systemctl start ts3server.service
sleep 5

IMPORTANT=$(cat "$TS3_DIR"/logs/*_1.log | grep -P -o "token=[a-zA-z0-9+]+")
clear
echo "$IMPORTANT" > "$TS3_DIR"/ServerAdmin_Privilege_Key.txt
echo -e "\nServerAdmin info je sacuvan u: '$TS3_DIR/ServerAdmin_Privilege_Key.txt'"
echo -e "ServerAdmin Privilege Key: $IMPORTANT\n"
echo ""
echo -e "\e[1m\e[92mScript by TheWitcher023\e[0m"
exit 0
