# CampusCoin Masternode
For your convenience, CampusCoin provides a shell script to help install your [CampusCoin Masternode](https://www.campuscoinproject.org/) on a Linux server running Ubuntu 16.04.  It should be noted that your masternode will not contain overly sensitive information.  Because of this, the use of 'root' is commonplace, and the masternode is easily replaced, refreshed, or updated.  Should you choose to separately store sensitive or confidential information on your masternode, please consider use of SSH keys, hardening scripts, and/or monitoring services.  Our focus here is on the CampusCoin Masternode, however a base hardening script is referenced for your consideration.

*CampusCoin provides no guarantees to the suitability or fitness of such code.  Use at your own discretion and at your own risk.

***
## CampusCoin Masternode Tiers

Please see the following table that outlines the three CampusCoin Masternode Tiers.  Before getting underway, it helps if you decide which tier level that you want to operate.

| TIER LEVEL     | CC REQUIRED |
| --- | --- |
| TIER I   |   500,000 CC |
| TIER II  | 1,000,000 CC |
| TIER III | 2,000,000 CC |

***
## VPS
Nearly any Virtual Server Provider (VPS) may be used.  Look for reputable companies that have been around for some time.  Some of these companies will advertise their uptime.  Higher uptime generally means higher costs.  Commonly used is Digital Ocean - https://www.digitalocean.com/pricing or Vultr - https://www.vultr.com/products/cloud-compute/#pricing.  You will need only a basic VPS, and the $5.00/month options at each - for our purposes - should be sufficient.
When last checked, machines at that price range offered the following specifications:

1 GB Memory
1 vCPU
25GB SSD
1 TB Transfer per month

***
## CampusCoin Installation:
1. Login as root
2. Run the following commands

***
#### (Optional) VPS Harden
*This step is optional, and highly recommended by our longtime supporter [BKCrypto1](https://github.com/BKCrypto1) to secure your VPS. 

As [BKCrypto1](https://github.com/BKCrypto1) points out, [NodeValet.io](https://nodevalet.io/) | [AKcryptoGUY's](https://github.com/akcryptoguy/vps-harden) team developed a robust VPS Hardening script. 
```
git clone https://github.com/akcryptoguy/vps-harden.git && cd vps-harden && bash get-hard.sh
```
**VPS-Harden will guide you through a series of steps to better secure your VPS. If you choose to run it, please complete to its entirety.**

Steps:
(AUTOMATED)
>  1. OS Updates
>  2. System Upgrades
>  3. Favored Packages
>  4. Crypto Packages

(USER SELECTIONS)
>  5. Create Non-Root User    (Y/N)
>  6. SSH Config              (Choose Port Number)
>  7. Pass Auth               (Y/N)
>  8. Firewall Config         (Y/N)
>  9. Hardening               (Y/N)
> 10. Ksplice Uptrack         (Y/N)
> 11. Enhance MOTD            (Y/N)
> 12. Restart SSH             (Y/N)

Once the script completes, please reconnect to your VPS to continue on to the Masternode Installation.
***

## Installation of your CampusCoin Masternode Service (v3.0.2.2)
```
wget https://raw.githubusercontent.com/campuscoindev/MASTERNODE/master/cc_mn_install.sh && bash cc_mn_install.sh
```

**CC_MN_Install will guide you through the installation of your New CampusCoin Masternode Service.**

Steps:
1. Installation of Dependencies
2. (Optional) Masternode Private Key - If you have one generated, you can place one here. If you do not have one, press enter.  A new key will be generated.
3. Download the latest CampusCoin Blockchain Snapshot
4. CampusCoin Masternode Server Startup

Complete. You will be provided with a bunch of masternode information. Save this information for the next step.

### RESOURCE:  If Needing To Update or Refresh An EXISTING CampusCoin Masternode Service
```
wget https://raw.githubusercontent.com/campuscoindev/MASTERNODE/master/cc_mn_update.sh && bash cc_mn_update.sh
```

REMINDER: If you used this script in the past, the bash script may need to be removed before you can run it again. 
```
rm -rf cc_mn_update.sh
```

***

## Desktop wallet setup

After your New CampusCoin Masternode is up and running, please configure your desktop wallet accordingly.
1. Open your CampusCoin (CC) Coin Desktop Wallet.
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
systemctl status CampusCoin      #Checks if the service is running.
systemctl start CampusCoin       #Start your CampusCoin service.
systemctl stop CampusCoin        #Stop your CampusCoin service.
systemctl is-enabled CampusCoin  #Checks if the CampusCoin service is enabled on boot.
```

## Help:

If you need any assistance, feel free to ask over at our [Discord](https://discord.gg/m6qUBKy) or [Telegram](https://t.me/CMPCO) channel.

***

## Thank You:

CampusCoin exists because of you, the members of our CampusCoin Community.  We cannot function without your ongoing support.  We encourage you to participate in our social media, and to tell others of your experience and help our CampusCoin Family to grow.  We need your support, and any way you can volunteer will help us to succeed.  If you would like to donate to help grow our project, anything you contribute goes right back into building the project.

Thanks,

CampusCoin Project

***

Type | Donation Address
------------- | -------------
CC | Cawn4BSvSuPFHk3wo43Nm85CG8TW1Y2s1H
BTC | 16QejfnTNUBhE2JRVmTMCRpi8j2kyqQu22
