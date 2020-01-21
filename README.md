# CampusCoin Masternode
Shell script to install a [CampusCoin Masternode](https://www.campuscoinproject.org/) on a Linux server running Ubuntu 16.04. 

*Use it on your own risk.

***
## CC Masternode Tiers

The Following Table represents the CC Masternode Tiers. It's a good idea to choose what tier you are looking to start prior to starting this setup.

| Tier             | Amount Required |
| --- | --- |
| Tier 1 | 500,000 CC |
| Tier 2 | 1,000,000 CC |
| Tier 3 | 2,000,000 CC |

***
## VPS
Sign up for either (referral link) [Digital Ocean](https://m.do.co/c/93c45618280e) or [Vultr](https://www.vultr.com/?ref=7763785) and set up a bare bones VPS. The $5/month option is sufficient for our needs. If you use the DO link above, you will get $100, 60-day credit.
- 1GB / 1CPU
- 25GB SSD
- 1TB Transfer

The install script will take care of the swap file for you.
***
## Installation:
1. Login as root
2. Run the following commands

***
#### (Optional) VPS Harden
*This step is optional, but highly recommended  to secure your VPS. 

[NodeValet.io](https://nodevalet.io/) | [AKcryptoGUY's](https://github.com/akcryptoguy/vps-harden) team developed a fantastic VPS Hardening script. 
```
git clone https://github.com/akcryptoguy/vps-harden.git && cd vps-harden && bash get-hard.sh
```
**VPS-Harden will guide you through a series of installation steps. Complete to its entirety.**

Steps:
(automated)
>1. OS Updates
>2. System Upgrades
>3. Favored Packages
>4. Crypto Packages

(User Selection)
>5. Create Non-Root User (y/n)
>6. SSH Config (Enter Port)
>7. Pass Auth (y/n)
>8. Firewall Config (y/n)
>9. Hardening (y/n)
>10. Ksplice Uptrack (y/n)
>11. Enhance MOTD (y/n)
>12. Restart SSH (y/n)

Complete & Reconnect to VPS

***

## Install CampusCoin Masternode Service (v3.0.2.2)
```
wget https://raw.githubusercontent.com/BKCrypto1/CC-MN/master/cc-install.sh && bash cc-install.sh
```

**CC-Install will guide you through the installation of the CampusCoin Masternode Service.**

Steps:
1. Installation of Dependencies
2. (optional) Masternode Private Key - If you have one generated, you can place one here. Otherwise, press enter to be provided with a newly generated key.
3. Download CC Blockchain Snapshot
4. CC Server Start

Complete. You will be provided with a bunch of masternode information. Save this information for the next step.

### Update Existing CampusCoin Masternode Service (Prior to v3.0.2.2)
```
wget https://raw.githubusercontent.com/BKCrypto1/CC-MN/master/update_cc_mn.sh && bash update_cc_mn.sh
```

Note: If you have used this script in the past, you may need to remove the old update file before downloading 
```
rm -rf update_cc_mn.sh
```

***

## Desktop wallet setup

After the MN is up and running, you need to configure the desktop wallet accordingly.
1. Open the CampusCoin (CC) Coin Desktop Wallet.
2. Go to RECEIVE and create a New Address: MN1
3. Send the required CC to MN1. (Choose which tier you want.)
4. Wait for at least 15 confirmations.
5. Go to Tools -> "Debug console"
6. Type the following command: 
```
masternode outputs
```
7. Go to Tools -> "Open Masternode Configuration File"
8. Add the following entry:
```
Alias IP:port MN_PrivateKey MN_Output_txid MN_Output_index
```

* Alias: MN1
* IP:port: VPS_IP:PORT
* MN_PrivateKey: Masternode Private Key
* MN_Output_txid: First value from Step 6
* MN_Output_index:  Second value from Step 6
9. Save and close the file.
10. Go to Tools -> "Open Wallet Configuration File"
11. Add the following entry:
```
externalip=IP:port
```
12. Save and close the file.
13. Close and Restart Wallet.
13. Go to Masternode Tab. If this tab is not shown, please enable it from: Settings - Options - Wallet - Show Masternodes Tab
14. Click Update status to see your node. If it is not shown, close the wallet and start it again. Make sure the wallet is unlocked.
15. Open Debug Console and type: (you can also click the start missing button)
```
masternode start-missing
```

or if you need to start a specific MN alias:

```
startmasternode "alias" 0
```
***

## VPS Usage:
```
cc-cli getinfo
cc-cli mnsync status
cc-cli masternode status
```
Also, if you want to check/start/stop CampusCoin , run one of the following commands as **root**:

**Ubuntu 16.04**:
```
systemctl status CampusCoin #To check the service is running.
systemctl start CampusCoin #To start CampusCoin service.
systemctl stop CampusCoin #To stop CampusCoin service.
systemctl is-enabled CampusCoin #This will check if the CampusCoin service is enabled on boot or not
```

If you need any assistance, feel free to stop by the [CampusCoin Discord](https://discord.gg/m6qUBKy) or [CampusCoin Telegram](https://t.me/CMPCO). I go by the name of BK in both Channels.

CC Donations: ```CNUfWFCDHH3711MbbF7Q7zTf7ctU6LkETi```

