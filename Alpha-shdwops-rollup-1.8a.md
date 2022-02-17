# Instructions for changes to Shadow Nodes
These changes will be in prep for the 1.8.15 Solana roll-up. It is ok to restart your nodes multiples time for these config changes.  

The 1.8.15 roll-up will contain a new parameter flag that we must set `--full-rpc-api` (otherwise your RPCs will cease to serve content or accept txn injection).

We suggest updating your RPC nodes first with the below changes, testing them in full, prior to rolling up to 1.8.15 in order to eliminate a confluence of unknowns causes of errors in the event something goes wrong with the 1.8.15 roll-up. 
#

## **Updates to `start-validator.sh`**
Create the following additional line to `export` items at the top of the `start-validator.sh` script. You can place it beneath `export RUST_BACKTRACE=1`

```
export GOOGLE_APPLICATION_CREDENTIALS=/home/sol/solarchival-e261c1f6eff5.json
```

Add the following parameter flags:
```
--rpc-send-default-max-retries 1 \
--rpc-send-retry-ms 2000 \
--rpc-send-service-max-retries 1 \
--account-index-exclude-key kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6 \
```

Remove:   
```
export SOLANA_METRICS_CONFIG=host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password

--rpc-pubsub-max-connections 1000 \
```
Modify existing params to the following (pairing back open ports):
```
--dynamic-port-range 8002-8012 \
```

## **GBT Access (Until replaced by Shadow Drive)**
This line should be added from above to map the GBT environmental variable
```
export GOOGLE_APPLICATION_CREDENTIALS=/home/sol/solarchival-e261c1f6eff5.json
```
We need to make sure `/home/sol/solarchival-e261c1f6eff5.json` is present. Download the read-only GBT key from the pinned resources in the Shadow-Ops discord channel and place into the `/home/sol` directly. You can use scp for this.  

When you download this file from the Shadow Ops Discord channel make sure you retain it in the `.json` format.

As an example:
```
scp C:\User\user-name\Desktop\solarchival-e261c1f6eff5.json root@123.123.123.123:/home/sol/
```
Change the local directory and the destination IP to that of your Shadow node. You will load the `.json` into the `/home/sol` directly and the new `export` line will map to this. Make sure and set the GBT `.json` key to user sol.
```
sudo chown sol:sol /home/sol/solarchival-e261c1f6eff5.json
```


## **TPU Blocking**
Set up new tool that blocks TPU/TPU Forwarding (shared by Triton One). This ensures Shadow Nodes are not propagating forwarder queue spam:  

as root
```

git clone https://github.com/rpcpool/tpu-traffic-classifier.git

cd ~/tpu-traffic-classifier

nano start-tpu.sh
```
edit into file
```
#! bin/bash
exec /root/tpu-traffic-classifier/tpu-traffic-classifier -config-file /root/tpu-traffic-classifier/config.yml -our-localhost -tpu-policy DROP -fwd-policy DROP -update=false
```
make executable
```
sudo chmod +x ~/start-tpu.sh
```
create system service
```
nano /etc/systemd/system/tpublock.service
```
edit into file
```
[Unit]
Description=RPC TPU Blocker
After=network.target
[Service]
Type=simple
Restart=on-failure
RestartSec=1
LogRateLimitIntervalSec=0
ExecStart=/root/tpu-traffic-classifier/start-tpu.sh --user root
[Install]
WantedBy=multi-user.target
```
save/exit/

```
systemctl enable --now tpublock.service
```
Verify the iptables show "DROP" on solana tpu and solana tpu forward
```
sudo iptables -L -v -n | more
```  

The `systemctl status sol.service` should return something similar to this identifying ports:

```
root@h1:~# systemctl status tpublock.service
● tpublock.service - RPC TPU Blocker
     Loaded: loaded (/etc/systemd/system/tpublock.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2022-02-02 13:35:46 UTC; 1 weeks 6 days ago
   Main PID: 43612 (tpu-traffic-cla)
      Tasks: 43 (limit: 7372)
     Memory: 49.5M
     CGroup: /system.slice/tpublock.service
             └─43612 /root/solana/tpu-traffic-classifier -config-file /root/solana/config.yml -our-localhost -tpu-policy DROP -fwd-policy DROP -update=false

Feb 16 07:55:59 h1 start-tpu.sh[43612]: 2022/02/16 07:55:59 validator ports set, identity= 7TigZTzw6u9kTL1XXLiWLHTbPSYjV5x667JdAFFEHn1Y  tpu= 8005 tpufwd= 8006 vote>
Feb 16 07:55:59 h1 start-tpu.sh[43612]: 2022/02/16 07:55:59 not updating ipsets
```
#
**These changes still need to be adding into the main configuration document for future Shadow Op onboarding. It is only partially complete at this time**