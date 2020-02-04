#!/bin/bash
# This script will install the CampusCoin (CC) Masternode.
function cc_banner() { 
echo -e "\e[32m"
cat << "EOF"
             ____                                 ____      _       
            / ___|__ _ _ __ ___  _ __  _   _ ___ / ___|___ (_)_ __  
           | |   / _` | '_ ` _ \| '_ \| | | / __| |   / _ \| | '_ \ 
           | |__| (_| | | | | | | |_) | |_| \__ \ |__| (_) | | | | |
            \____\__,_|_| |_| |_| .__/ \__,_|___/\____\___/|_|_| |_|
                                |_|                                 
 _______ _______ _______ _______ _______  ______ __   _  _____  ______  _______
 |  |  | |_____| |______    |    |______ |_____/ | \  | |     | |     \ |______
 |  |  | |     | ______|    |    |______ |    \_ |  \_| |_____| |_____/ |______
                                                                               
EOF
echo -e "\e[0m"
#"${NC}"
}

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='cc.conf'
CONFIGFOLDER='/root/.cc'
COIN_DAEMON='ccd'
COIN_CLI='cc-cli'
                    # COIN_TX='cc-tx'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/campuscoindev/CC/releases/download/3.0.2.2/cc_linux.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_SNAPSHOT='https://www.dropbox.com/s/p66flxb99blv509/CC-SNAPSHOT-FEB03-2020-FULL-TO-BLK1235040.zip'
COIN_NAME='CampusCoin'
COIN_PORT=28195
RPC_PORT=28196

NODEIP=$(curl -s4 icanhazip.com)

RED="\033[38;5;196m"
GREEN="\033[38;5;46m"
BLUE="\033[34m"
PINK="\033[0;31m"
NC="\033[0m"

function download_node() {
  echo -e "${BLUE}Prepare to download ${GREEN}Official $COIN_NAME Linux Package${NC}."
  cd $TMP_FOLDER >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  unzip $COIN_ZIP >/dev/null 2>&1
  #cd bin #verify
  chmod +x $COIN_DAEMON $COIN_CLI # $COIN_TX 
  cp $COIN_DAEMON $COIN_CLI $COIN_PATH # $COIN_TX
  cd ~ >/dev/null
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}

function download_snapshot() {
  echo -e "${BLUE}Prepare to download ${GREEN}Official $COIN_NAME Snapshot${NC}."
  TMP_FOLDER=$(mktemp -d)
  cd $TMP_FOLDER
  wget --progress=bar:force $COIN_SNAPSHOT 2>&1
  unzip CC-SNAPSHOT-FEB03-2020-FULL-TO-BLK1235040.zip -d $CONFIGFOLDER/
  cd -
  rm -rf $TMP_FOLDER >/dev/null 2>&1
}

function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=root
Group=root
Type=forking
        #PIDFile=$CONFIGFOLDER/$COIN_NAME.pid
ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_DAEMON$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}***WARNING*** $COIN_NAME IS NOT RUNNING ***WARNING***${NC}.  Please investigate. Recommend you start by running the following commands as root:"
    echo -e "systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog"
    exit 1
  fi
}


function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
        #rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
staking=0
port=$COIN_PORT
EOF
}

function create_key() {
  echo -e "Enter your ${RED}Masternode Private Key${NC}, or leave it blank to generate a brand new ${RED}Masternode Private Key${NC}:"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  $COIN_PATH$COIN_DAEMON -daemon
  sleep 30
 if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "${RED}***WARNING*** $COIN_NAME SERVER COULD NOT START. ${PINK}Check /var/log/syslog for errors.${NC}"
   exit 1
  fi
  COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  if [ "$?" -gt "0" ];
    then
    echo -e "${PINK}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
    sleep 30
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  fi
  $COIN_PATH$COIN_CLI stop
fi
clear
}

function update_config() {
        #sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=256
               #bind=$NODEIP
masternode=1
masternodeaddr=$NODEIP:$COIN_PORT
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
EOF
}


function enable_firewall() {
  echo -e "${BLUE}Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

 if [ ${#NODE_IPS[@]} -gt 1 ]
   then
      echo -e "${RED}More than one IP is detected. ${NC}Please type 0 to use the first IP, 1 for the second and so on..."
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}

function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${PINK}Failed to build Masternode. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${PINK}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${PINK}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "\e[32m$COIN_NAME is already installed.${NC}"
  exit 1
fi
}

function prepare_system() {
echo -e "${GREEN}Preparing the system to install NEW $COIN_NAME MASTERNODE.${NC}"
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1 
apt install -y software-properties-common >/dev/null 2>&1 
echo -e "${BLUE}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "${BLUE}Installing required packages.  ${NC}This may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool unzip autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev \
libdb4.8 libdb4.8++ libboost-system1.58.0 libboost-filesystem1.58.0 \
libboost-program-options1.58.0 libboost-thread1.58.0 libssl1.0.0 libminiupnpc10 libevent-2.0-5 \
libevent-pthreads-2.0-5 libevent-core-2.0-5 libminiupnpc-dev libzmq3-dev git nano tmux curl wget pwgen libzmq3-dev libboost-all-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev >/dev/null 2>&1
apt-get install -y libgmp3-dev >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${PINK}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make software-properties-common build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev libdb5.3-dev libdb5.3++-dev libminiupnpc-dev libzmq3-dev git nano tmux libgmp3-dev"
 exit 1
fi
clear
}

function create_swap() {
 echo -e "${BLUE}Checking if swap space is needed."
 PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
 SWAP=$(swapon -s)
 if [[ "$PHYMEM" -lt "2"  &&  -z "$SWAP" ]]
  then
    echo -e "${GREEN}Server is running with less than 2G of RAM without SWAP, creating 2G swap file.${NC}"
    SWAPFILE=$(mktemp)
    dd if=/dev/zero of=$SWAPFILE bs=1024 count=2M
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon -a $SWAPFILE
 else
  echo -e "${BLUE}The server is identified as either running with at least 2G of RAM, or a SWAP file is already in place.${NC}"
 fi
 clear
}

function important_information() {
awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
    s="/\\";
    for (colnum = 0; colnum<term_cols; colnum++) {
        r = 255-(colnum*255/term_cols);
        g = (colnum*510/term_cols);
        b = (colnum*255/term_cols);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum%2+1,1);
    }
    printf "\n";
}'
 echo -e "\e[32m================================================================================================================================${NC}"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "Please check $COIN_NAME daemon is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your Masternode."
 if [[ -n $SENTINEL_REPO  ]]; then
  echo -e "Sentinel is installed in ${RED}$CONFIGFOLDER/sentinel${NC}"
  echo -e "Sentinel logs is: ${RED}$CONFIGFOLDER/sentinel.log${NC}"
 fi
 echo -e "\e[32m================================================================================================================================${NC}"
awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
    s="/\\";
    for (colnum = 0; colnum<term_cols; colnum++) {
        r = 255-(colnum*255/term_cols);
        g = (colnum*510/term_cols);
        b = (colnum*255/term_cols);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum%2+1,1);
    }
    printf "\n";
}'
}
function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  enable_firewall
  important_information
  configure_systemd
}


##### Main #####
#clear
cc_banner
checks
prepare_system
create_swap
download_node
download_snapshot
setup_node
