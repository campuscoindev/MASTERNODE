#!/bin/bash
# This script will update your existing CampusCoin (CC) Masternode.
function cc_banner() { 
echo -e "\e[32m"
cat << "EOF"
   ____                                 ____      _       
  / ___|__ _ _ __ ___  _ __  _   _ ___ / ___|___ (_)_ __  
 | |   / _` | '_ ` _ \| '_ \| | | / __| |   / _ \| | '_ \ 
 | |__| (_| | | | | | | |_) | |_| \__ \ |__| (_) | | | | |
  \____\__,_|_| |_| |_| .__/ \__,_|___/\____\___/|_|_| |_|
                      |_|                                 
EOF
echo -e "\e[0m"
}

function set_colors() { 
RED="\033[38;5;196m"
GREEN="\033[38;5;46m"
BLUE="\033[34m"
NC="\033[0m"

}
function set_variables() {
CONFIGFOLDER="/root/.cc"
COIN_SNAPSHOT="https://www.dropbox.com/s/twstpudu0g7gc5x/CC-SNAPSHOT-MAR26-2020-FULL-TO-BLK1305902.zip"
}
function stop_service() {
echo -e "${RED}Stopping CC MasterNode Service${NC}"
systemctl stop CampusCoin.service
cd /usr/local/bin/
}
function get_latest() {
echo -e "${GREEN}Retrieving latest Official CC Linux binary...${NC}"
wget -c https://github.com/campuscoindev/CC/releases/download/3.0.2.2/cc_linux.zip
}

function remove_old() {
echo -e "${RED}Removing old CC files...${NC}"
sudo rm ccd cc-cli cc-tx
sudo rm cc-qt
#######sudo rm -R ~/.cc/backups/
sudo rm -R ~/.cc/blocks/
sudo rm -R ~/.cc/chainstate/
sudo rm -R ~/.cc/database/
sudo rm ~/.cc/budget.dat ~/.cc/db.log ~/.cc/debug.log ~/.cc/fee_estimates.dat ~/.cc/mncache.dat ~/.cc/mnpayments.dat ~/.cc/peers.dat
}

function install_latest() {
echo -e "${GREEN}Extracting zip archive...${NC}"
sudo unzip cc_linux.zip
echo -e "${GREEN}Performing Cleanup...${NC}"
sudo rm cc_linux.zip
}

function get_snapshot() {
echo -e "${GREEN}Retrieve Latest Official CC Snapshot...${NC}"
TMP_FOLDER=$(mktemp -d)
  cd $TMP_FOLDER
  wget --progress=bar:force $COIN_SNAPSHOT 2>&1
  unzip CC-SNAPSHOT-MAR26-2020-FULL-TO-BLK1305902.zip -d $CONFIGFOLDER/
  cd -
  rm -rf $TMP_FOLDER >/dev/null 2>&1
}

function start_service() {
echo -e "${GREEN}Starting CC Service..."
systemctl start CampusCoin.service
}

function finish() {
echo -e "${GREEN}CC Masternode Updated.${NC}"
echo -e "------------------------------------------------------------------"
echo -e "${BLUE}Useful Commands:${NC}"
echo -e "Use ${BLUE}cc-cli masternode status${NC} to check masternode status."
echo -e "Use ${BLUE}cc-cli mnsync status${NC} to check IsBlockchainSynced."
echo -e "Use ${BLUE}cc-cli getconnectioncount${NC} to check connections."
echo -e "Use ${BLUE}cc-cli getblockcount${NC} to view current block count."
echo -e "Use ${BLUE}cc-cli getinfo${NC} to view coin info."
echo -e "----------------------------------------------------------------------------------------------"
echo -e "\e[32mThank you for adding strength to the CampusCoin Community with your Updated CampusCoin MasterNode! \e[0m"
echo -e "----------------------------------------------------------------------------------------------"
}

# main
set_colors
cc_banner
set_variables
stop_service
remove_old
get_latest
install_latest
get_snapshot
start_service
finish

exit
