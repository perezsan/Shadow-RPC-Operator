# RPC Node config for Equinix Metal

Make sure and check out the START-HERE document.

IMPORTANT: This guide is specifically for Equinix Machines from the Solana Reserve pool accessed through he Solana Foundation Server Program. https://solana.foundation/server-program

You must be running Ubuntu 20.04

So you have your shiny new beast of a server. Let's make it a Shadow Operator RPC.

First things first - OS security updates
```
apt update
apt upgrade
apt dist-upgrade
```
create user sol

```
adduser sol

usermod -aG sudo sol

su - sol

```

**Hostname Creation**

In order for the shadow network to accept your machine, you need to set your hostname with the following parameters:

**You must use the following for your hostname or your request to join the network will be rejected**:

```shadow-<region>-<discordname>-<discordusernumber>-<servercount>```

For example, if you are in the North American region and your discord name is johndoe#1234, your server would be:

```shadow-na-johndoe-1234-01```

The server count represents your personal shadow nodes.  If you only have 1, it would be 01, if you have 2 and this is your second, it would be 02, and so on.
You can set your hostname with the following command:

```sudo hostnamectl set-hostname newNameHere``` 

Partition hard drive for RPC
Partition NVME into 420gb (swap) and 3000gb (ledger and accounts)

adding new process using GPT partition with gdisk for larger filessytems. Make larger 3.5 (or 3.8) TB drive via gdisk then partition using fdisk as normal. You have to delete the original GPT in order to select partition 1 with fdisk

Enter the "n" then hit enter
Etner the "1" then hit enter...and so on
```
sudo gdisk /dev/nvme0n1
n, 1, p, 2048, [max secor available], 8300, p, w
```
note the first step in the next section is deleting the partition we just created above
```
sudo fdisk /dev/nvme0n1
d, n, p, 1 or 2, default sector, +3000GB, n, p, 1 or 2, default sector, +420GB, w
```
Now make filessytems, directories, delete and make new swap, etc.
```
sudo fdisk -l 

sudo mkfs -t ext4 /dev/nvme0n1p1

sudo mkfs -t ext4 /dev/nvme0n1p2

sudo mkdir /mnt/

sudo mkdir /mnt/ramdrive

sudo mkdir /mt/

sudo mkdir /mt/ledger

sudo mkdir /mt/ledger/validator-ledger

sudo mkdir /mt/solana-accounts

sudo mkdir ~/log
```
Discover the swap directory, turn it off, make a new one and turn it on
```
sudo swapon --show

```
You need to look at the directory and pick the correct /dev/sd*

It could be /dev/sdb2 or /dev/sdc2 so edit the next line below to the proper sd**

It will almost always be the one showig 1.9GB of swap size
```
sudo swapoff /dev/sda2

sudo sed --in-place '/swap.img/d' /etc/fstab

sudo mount /dev/nvme0n1p2 /mnt/

sudo mount /dev/nvme0n1p1 /mt

sudo dd if=/dev/zero of=/mnt/swapfile bs=1M count=350k
```
It can take up to 5 minutes for the machine to make this size swapfile. Sit tight.

Next is setting permissions and adding the swapfile to fstab, then edit the swapiness to 30.
```
sudo chmod 600 /mnt/swapfile

sudo mkswap /mnt/swapfile

echo 'vm.swappiness=30' | sudo tee --append /etc/sysctl.conf > /dev/null

sudo sysctl -p

sudo swapon --all --verbose
```
Capture nvme0n1p1 and nvme0n1p2 UUIDs to edit into /etc/fstab

Let's take a look at the file first to get an idea of what is needed here.
```
sudo nano /etc/fstab
```
You should see something similar to this:
UUID=e6eafc79-85c3-4208-82ac-41b73d75cd31       /       ext4    errors=remount-ro       0       1
UUID=4b8f8a7b-8b8f-4984-a341-5770f8b365a1       none    swap    none    0       0

These are the default OS drives and should be left alone. Do not overwrite them. You will need to add the two new UUID's of the two partitions you just made (nvmeon1p1 and nvme0n1p2).

```
lsblk -f
```
Copy the section that looks similar to the below nvme0n1 partition tree and past it into a notepad (or VScode, etc) so that you can copy/past into fstab properly. We just need the UUID's so in the example below copy "5c24e241-239c-4aa5-baa6-fbb6fb44a847" and "87645b08-85c2-4fe2-9974-1bda4de317d9" and note which partition each belongs to (/mt and /mnt respectively). Your UUIDs will be different!
```
nvme0n1
├─nvme0n1p1 ext4         5c24e241-239c-4aa5-baa6-fbb6fb44a847    2.8T     0% /mt
└─nvme0n1p2 ext4         87645b08-85c2-4fe2-9974-1bda4de317d9    9.5G    88% /mnt
```
These UUID above need to be edited into the fstab config below
```
sudo nano /etc/fstab
```
dump this into fstab below the current UUIDs. delete or hash out the old swap UUID if needed. Leave the first UUIDs (OS related), just **append these lines under whatever current UUIDs are listed** as the ones already in the file are boot/OS related.
also make sure UUID is correct as they can change

Once you update the UUIDs below (which are just examples) to the ones you gathered from your machine, paste this into the fstab file mentioned above **underneath the existing file entries**.
```
#GenesysGo RPC config
UUID=5c24e241-239c-4aa5-baa6-fbb6fb44a847 /mt  auto nosuid,nodev,nofail 0 0
UUID=87645b08-85c2-4fe2-9974-1bda4de317d9 /mnt  auto nosuid,nodev,nofail 0 0
#ramdrive and swap
#tmpfs /mnt/ramdrive tmpfs rw,size=50G 0 0
/mnt/swapfile none swap sw 0 0
```
save / exit
ctrl+s, ctrl+x

But Wait - what was that ramdrive and tmpfs stuff? Leave it for now. That is an performance enhancement option that will be covered in later documentation. In short, it's for running the solana-accounts inside the memory of the server versus on the hard drive. More on this later.

The complete file should look like this (but with your own UUIDs):
```
UUID=e6eafc79-85c3-4208-82ac-41b73d75cd31       /       ext4    errors=remount-ro       0       1
UUID=4b8f8a7b-8b8f-4984-a341-5770f8b365a1       none    swap    none    0       0
#GenesysGo RPC config
UUID=5c24e241-239c-4aa5-baa6-fbb6fb44a847 /mt  auto nosuid,nodev,nofail 0 0
UUID=87645b08-85c2-4fe2-9974-1bda4de317d9 /mnt  auto nosuid,nodev,nofail 0 0
#ramdrive and swap
#tmpfs /mnt/ramdrive tmpfs rw,size=60G 0 0
/mnt/swapfile none swap sw 0 0
now edit permissions and make sure user sol is the owner for solana directories
```

```
sudo chown sol:sol /mt/solana-accounts

sudo chown sol:sol /mt/ledger

sudo chown sol:sol ~/log

sudo chown sol:sol /mt/ledger/validator-ledger
```
Mount everything.
```
sudo mount --all --verbose
```

Set up the firewall / ssh
```
sudo snap install ufw

sudo ufw enable

sudo ufw allow ssh
```
There are additional ports in prep for open source monitoring stack and other networking features. It is important to understand how UFW works and how to manage the attack surface of the machine. If you want to identify the ports solana needs (8000-8020) and reduce your attack surface by only enable those at this time please do. As Shadow Protocol evolves so will the port exposures and the need for awareness around those.

Dump this entire command block for basic Shadow Node function:
```
sudo ufw allow 53;sudo ufw allow 8899/tcp;sudo ufw allow 8900/tcp;sudo ufw allow 8000:8020/tcp;sudo ufw allow 8000:8020/udp
```
These additional rules are in preparation for more Shadow Protocol features. Just drop this expanded rules block when there is a request from the team to expand ports:
```
sudo ufw allow 80;sudo ufw allow 80/udp;sudo ufw allow 80/tcp;sudo ufw allow 53;sudo ufw allow 53/tcp;sudo ufw allow 53/udp;sudo ufw allow 8899;sudo ufw allow 8899/tcp;sudo ufw allow 8900/tcp;sudo ufw allow 8900/udp;sudo ufw allow 8901/tcp;sudo ufw allow 8901/udp;sudo ufw allow 9900/udp;sudo ufw allow 9900/tcp;sudo ufw allow 9900;sudo ufw allow 8899/udp;sudo ufw allow 8900;sudo ufw allow 8000:8020/tcp;sudo ufw allow 8000:8020/udp
```
# Install the Solana CLI! Don't forget to check for current version (1.8.11 as of 12/14/21)

```
sh -c "$(curl -sSfL https://release.solana.com/v1.8.11/install)"
```
I will ask you to map the PATH just copy and paste the blow:
```
export PATH="/home/sol/.local/share/solana/install/active_release/bin:$PATH"
```
You are now able to join Solana gossip which is an overarching network communication layer which all RPCs and Validators chatter in. If you see a steam of logs, and no errors then have officially connected directly to the Solana network.

```
solana-gossip spy --entrypoint entrypoint.mainnet-beta.solana.com:8001
```
If your machine is gossiping without any errors it can be spun up on the mainnet to start reading the chain data.

exit gossip with ctrl + c

Now create keys.

RPCs use throw away keys. These keys allow and RPC to be fully functional but do not need funds and do not need to be saved (because you can just make new ones if you need to ). You do not need to set a password for the keys. No need to copy seed phrases. You do not need a wallet-keypair if just RPC. **Do not move SOL into these wallets. This is not a validator**
```
solana-keygen new -o ~/validator-keypair.json

solana config set --keypair ~/validator-keypair.json

solana-keygen new -o ~/vote-account-keypair.json
```
making system services (sol.service and systuner.service) and the startup script.

this is the solana-validator start up shell script which the system service (sol.service) will reference
```
sudo nano ~/start-validator.sh
```
dump this into start-validator.sh:

```
#!/bin/bash
# v0.5 Shadow Node ( updated 12/14/2021)
export SOLANA_METRICS_CONFIG=host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password
PATH=/home/sol/.local/share/solana/install/active_release/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
export RUST_BACKTRACE=1
export RUST_LOG=solana=info,solana_core::rpc=debug
exec solana-validator \
    --identity ~/validator-keypair.json \
    --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
    --known-validator 7cVfgArCheMR6Cs4t6vz5rfnqd56vZq4ndaBrY5xkxXy \
    --known-validator DDnAqxJVFo2GVTujibHt5cjevHMSE9bo8HJaydHoshdp \
    --known-validator Ninja1spj6n9t5hVYgF3PdnYz2PLnkt7rvaw3firmjs \
    --known-validator wWf94sVnaXHzBYrePsRUyesq6ofndocfBH6EmzdgKMS \
    --known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
    --known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
    --known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
    --known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
    --rpc-port 8899 \
    --dynamic-port-range 8002-8020 \
    --no-port-check \
    --gossip-port 8001 \
    --no-untrusted-rpc \
    --no-voting \
    --private-rpc \
    --rpc-bind-address 0.0.0.0 \
    --rpc-send-retry-ms 100 \
    --enable-cpi-and-log-storage \
    --enable-rpc-transaction-history \
    --enable-rpc-bigtable-ledger-storage \
    --rpc-bigtable-timeout 300 \
    --account-index program-id \
    --account-index spl-token-owner \
    --account-index spl-token-mint \
    --rpc-pubsub-enable-vote-subscription \
    --no-duplicate-instance-check \
    --wal-recovery-mode skip_any_corrupted_record \
    --vote-account ~/vote-account-keypair.json \
    --log ~/log/solana-validator.log \
    --accounts /mt/solana-accounts \
    --ledger /mt/ledger/validator-ledger \
    --limit-ledger-size 700000000 \
    --rpc-pubsub-max-connections 1000 \

```
save / exit (ctrl+s then ctrl+x)

Make this shell file executable.
```
sudo chmod +x ~/start-validator.sh
```
Change the ownership to user sol
```
sudo chown sol:sol start-validator.sh
```
Create the Solana system service - sol.service (run on boot, auto-restart when sys fail) 
```
sudo nano /etc/systemd/system/sol.service
```
Dump this into file:
```
[Unit]
Description=Solana Validator
After=network.target
Wants=systuner.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=1
LimitNOFILE=1000000
LogRateLimitIntervalSec=0
User=sol
Environment=PATH=/bin:/usr/bin:/home/sol/.local/share/solana/install/active_release/bin
Environment=SOLANA_METRICS_CONFIG=host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password
ExecStart=/home/sol/start-validator.sh

[Install]
WantedBy=multi-user.target
```
save/exit (ctrl+s then ctrl+x)

Make system tuner service - systuner.service
```
sudo nano /etc/systemd/system/systuner.service
```
Dump this into file:
```
[Unit]
Description=Solana System Tuner
After=network.target
[Service]
Type=simple
Restart=on-failure
RestartSec=1
LogRateLimitIntervalSec=0
ExecStart=/home/sol/.local/share/solana/install/active_release/bin/solana-sys-tuner --user sol
[Install]
WantedBy=multi-user.target
```
Reload the system services
```
sudo systemctl daemon-reload
```
Create log rotation for ~/log/solana-validator.log
```
sudo nano /etc/logrotate.d/solana
```
dump this into file:
```
/home/sol/log/solana-validator.log {
  su sol sol
  daily
  rotate 1
  missingok
  postrotate
    systemctl kill -s USR1 sol.service
  endscript
}
```
Reset log rotate
```
sudo systemctl restart logrotate
```

Set CPU to performance mode (careful with this if you are adapting these configs to different hardware)
```
sudo apt-get install cpufrequtils

echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

sudo systemctl disable ondemand
```
modifications to sysctl.conf
```
sudo nano /etc/sysctl.conf
```
edit into bottom of file

```
# other tunings suggested by Triton One
# sysctl_optimisations:
vm.max_map_count=1000000
vm.swappiness=20
kernel.hung_task_timeout_secs=300
vm.stat_interval=10
vm.dirty_ratio=40
vm.dirty_background_ratio=10
vm.dirty_expire_centisecs=36000
vm.dirty_writeback_centisecs=3000
vm.dirtytime_expire_seconds=43200
kernel.timer_migration=0
# A suggested value for pid_max is 1024 * <# of cpu cores/threads in system>
kernel.pid_max=49152
net.ipv4.tcp_fastopen=3
# solana systuner
net.core.rmem_max=134217728
net.core.rmem_default=134217728
net.core.wmem_max=134217728
net.core.wmem_default=134217728
```

# Start up and test the Shadow Node

```
sudo systemctl enable --now systuner.service

sudo systemctl status systuner.service

sudo systemctl enable --now sol.service

sudo systemctl status sol.service
```
Note that you may need to type :q (i.e. colon followed by q) to get back to the shell prompt. <br>

Or you can run with the bash (prefer the above - this option to use bash is just for debugging). If you are newer to Linux, and do not yet know how to use tmux, or screen then you should read up on terminal multiplexers.
```
tmux

bash start-validator.sh
```
Tail the log to make sure it's fetching snapshot and working
```
sudo tail -f ~/log/solana-validator.log
```
The result should be a log stream that is attempting to find trusted Solana nodes to download your very first snapshot. A snapshot is a fragment of the total ledger and will allow your machines to identity ledger state and race to the tip if the chain. It can take up to 20 minutes to download a snapshot and begin catching up. The catchup can take up to 45 minutes as well. You can run healthchecks to know when the machine is on the top of the chain (healthy and ready to serve data) by using some of the below commands:

Healthcheck - you want this to return the work "Ok"

If can also return a 'behind by x number of slots" which means it behind the "tip" of the chain by that many slots. Nodes can sometimes fall a little behind and that's normal. Anything above about 100 behind mean you will risk serving stale data.

It can take half an hour before this healthcheck reports slots. Prior it may just say "connection refused." That's normal, give the RPC time to download the data, index the data, and catch up to the top of the chain.
```
curl http://localhost:8899 -k -X POST -H "Content-Type: application/json" -d '
  {"jsonrpc":"2.0","id":1, "method":"getHealth"}
'
```

Please see [shadow_monitoring](./Shadow-RPC-Operator/shadow_monitoring/README.md) for a guide on settin uo your own observability stack. This allows you to view your Shadow RPC Node's metrics (hardware health, network health, etc.).


Tracking root slot
```
timeout 120 solana catchup --our-localhost=8899 --log --follow --commitment root
```
curl for getBlockProduction - this is a simple curl and calls for a little bit larger JSON data response. It should be nearly instant. If it isn't there is a problem.
```
curl http://localhost:8899 -k -X POST -H "Content-Type: application/json" -H "Referer: SSCLabs" -d '{"jsonrpc":"2.0","id":1, "method":"getBlockProduction"}
'
```
Further health checks coming soon including health checks for archival data. Shadow Nodes will store all transactions back to the genesis block 0. More curls will be placed here to make sure your node properly accesses archival. 


