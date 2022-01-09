# Shadow Node FAQ & Maintenacne Guide

This FAQ is a DAO-owned community driven effort to collect knowledge on understanding and troubleshooting the Shadow RPC Node. There are two responses to each subject: 1) a short technical one, and 2) a full explanation.

Update 01/08/2022 - most technical responses have been started, with full explanations to follow. Please feel free to submit PR's to this resource and help build out the knowledge base.


##
**How do I know if it set up the node properly and it will connect?**

Tech:
`sudo systemctl status sol.service` - the service should be active
`sudo tail -f ~/log/solana-validator.log` - this log should be streaming. Grep this log for error or warning `sudo tail -f ~/log/solana-validator.log | grep "WARN"` or `sudo tail -f ~/log/solana-validator.log | grep "ERROR"` 
check health - `curl http://localhost:8899 -k -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getHealth"}'`

Full:
Using `sudo systemctl status sol.service` is checking for the sol.service system process. You created this in the file /etc/systemd/system/sol.service folder. This is where many system processes live and they run in the background. Solana service, the system tuner, and the log rotation for the solana log file are all processes you created in set up and they run by themselves when you start or restart the server. If there is a failure of the node, the system services restart on their own. `sudo systemctl status sol.service` check to see if it's alive. If it isn't - you need to hunt down why in the logs.

##
**How do I hunt for issues in logs?**

Tech:
`sudo cat /var/log/syslog` 
`sudo cat ~/log/solana-validator.log | grep "
	
Full:
You want to learn to tail, cat, and filter the solana validator log. You also need to learn that when something goes wrong both the solana log and the syslog have answers. Determining the cause of a critical fault is often identifying the error in the log, and then identifying the time that it happned, and comparing that time across your other logs (like syslog or kernlog or OOM logs). The Solana RPC produces a information rich log and you will need to get familiar parsing it.

##
**I followed the guide, but it will not connect to the cluster.**

Tech:
Restart node.
Check firewall `sudo ufw status` to make sure allowed ports align with config doc.
Check `sudo nano ~/start-validator.sh` to make sure there are no syntax errors
Check permissions on `/mt/solana-accounts` and `/mt/ledger/validator-ledger` all should be owned by user `sol`
Check syntax in all of the files you created - `/etc/systemd/system/sol.service`, `/etc/systemd/system/systuner.service`, `/etc/lograte.d/solana`
Ping something. Ping yourself. Check for NIC errors `

##
**Why does my node keep falling behind?**

Tech:
`timeout 120 solana catchup --our-localhost=8899 --log --follow --commitment root` - is it gaining or losing position on the chain?
`curl http://localhost:8899 -k -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getHealth"}'` - health should read OK
Check entrypoints In `sudo nano ~/start-validator.sh` and run `traceroute entrypoint2.mainnet-beta.solana.com:8001` on all the entries. Routes over 100ms are not ideal.
Check CPU - `sudo apt get cpufrequtils` and `lscpu`
Check NIC - 
Stop solana, restart systuner, restart solana - `sudo systemctl stop sol.service` - `sudo systemctl restart systuner.service` - `sudo systemctl enable --now sol.service`
	
Full:
Welcome to the world's fastest blockchain. It's a common facet of node operation. Solana Shadow nodes should be max boosting CPU with low latency connections. A node will fall behind for 3 main reasons: 1) you were on a bad fork, 2) your hardware is not acting proper or tuned proper, 3) there are network problems.
1 - Validators occasionally produce bad block or forks and RPC can get snagged or tangled in these moments. The machine might fall behind anywhere from 100 to 500 slots depending on many aspect of your network topology relative to validator global epicenters and leader validator location when the fork occurred. The machine should redover if configured properly. The Shadow Protocol is aware of this and compensates by removing RPC from live traffic during these events allowing them to catch up. Part of delivering higher quality of service on chain is actively managing you condition of your node relative to the very top of the chain.
2 - CPU should be static (or boosting) all cores above 3GHZ and your hard drives capable of over 5,000 IOPS
3 - There should be an entrypoint that you can ping or run a traceroute on that provides a low latency entry into the gossip network. You should be able to ping local validator or the Shadow Protocl's local load balancer and get sub 100ms (ideally sub 60ms) pings.
	
If your node falls off the tip by about 100-300 slots and recovers in a matter of seconds that is common. If it is nose diving or falling very behind you have a problem. 

##
**Why did my node just restart and my health check shows "connection refused?"**
	
Tech: 
Check swap and virtual memory allocations. 
Check OOM killer
Check packet loss, NIC errors
Flush IP tables and reset UFW with the following large command block (drop to root to do this) and restart afterwards:
`ufw disable;apt-get remove ufw;apt-get purge ufw;iptables -P INPUT ACCEPT;iptables -P FORWARD ACCEPT;iptables -P OUTPUT ACCEPT;iptables -F;iptables -X;iptables -Z ;iptables -t nat -F;iptables -t nat -X;iptables -t mangle -F;iptables -t mangle -X;iptables -t raw -F;iptables -t raw -X;apt update;apt upgrade;apt dist-upgrade;apt install ufw;ufw enable;ufw allow ssh;ufw allow 22;ufw allow 80;ufw allow 80/udp;ufw allow 80/tcp;ufw allow 53;ufw allow 53/tcp;ufw allow 53/udp;ufw allow 8899;ufw allow 8899/tcp;ufw allow 8900/tcp;ufw allow 8900/udp;ufw allow 8901/tcp;ufw allow 8901/udp;ufw allow 9900/udp;ufw allow 9900/tcp;ufw allow 9900;ufw allow 8899/udp;ufw allow 8900;ufw allow 8000:8020/tcp;ufw allow 8000:8020/udp`

Full:
Nodes can become unhealthy enough to being restarting all on their own (the Solana software will restart, not the physical machine). The system process `/etc/systemd/system/sol.service` has an automatic restart parameter so the node will try and reboot immediatley and get back to the tip. If you aren't around when this happens you have to filters logs to try and determine the cause. It could be that memory allocations are too low and the OOM (Out of memory killer) is coming after you. Or you could be encounter network disconnections. It's also possible it's as simple as you are on the wrong version of solana. Run through all the other troubleshooting problems and share your logs with the Shadow Ops discord channel to get help.

##
**How do I see how many clients are connected?**

Tech:
`netstat -s` all TCP and UDP conections
`netstat -an | grep ESTABLISHED | wc -l` - open ports that are established
`nc -vz {host} {port}` test host and port

Full:
need some examples here and deferal to grafana dashboards

##
**How do I know if I am serving errors?**

Tech:
	
	
Full:
One of the best ways to know if you are properly serving content is the run queireis (called curls) against your node. The more you play with these curls the more you will understand what is being asked of your machines and exactly how the data look when it is served out by Shadow Protocol. Here are some additional curls (makes ure and replace them with your IP):
	
(neec to finish) curls here

In addition to this you should monitor TCP packet loss or TCP connections drops by using the grafana observability stack. This is open source code and the DAO owns a guide that help you install this monitoring on your node.


**What do I do if I have been put on stand-by by the shadow protocol?**
	
Full:
Check time of stanby. Check your grafana stack for machines metrics that fall out of tolerance and correspond to the time you were placed on standby
Run health curls and self stress tests on your machines.

**My hard drive fills up too fast or is full.**

Tech: 
Check logrotate.
Check ledger size in `~/start-validator.sh` making sure --limit-ledger-size is `700000000`
Check PIDs for a ghost log. The machine may have rotated logs properly but there is a hung PID tricking the kernel.
	
	
Full:
You may not be properly rotating logs. One of the most common mistakes is incorreclty stating the log directly inside the `/etc/logrotate.d/solana` where it should point at `~/log/solana-validator.log`
You might have also hit the 0 key one too many times in the `~/start-validator.sh` file o the line that says `--limit-ledger-size 700000000 \`
Use commands like `df -l` to check hard drive space and `ls -la` to list files by their sizes


**How do I know if my machine is secure?**

Tech:
Check Firewall `sudo ufw status` and limit ports to only those needed in the config. 
SSH access should be key entry only
Check IP access logs (see IP accessing your machine)
	
##
#help finish this
##
	
Full:
UFW blocks port unless you tell it to open them. Even if you allow port access, you still have to have software that open and closes the ports. The fact that UFW allows ports 8000-8020/tcp/udp for example to be accessible still requires sending the correct languqge to enter the port andf for the solana software to recognix the incoming requests and open the port. If there is a port that is open an it doesn't have a purpose then close it. If you are not sure then ask a fellow Shadow Ops. Here is a list of ports and what they do:
	
53
80
8001
8002:8020/tcp/udp
	
#Finish this

**What type of hardware checks should I run?**

Tech:
Cpefrequtils (finish this)
NIC
	
Full:
Pay attention to yrou grafana dashboard. Know what is normal and what isn't. 40% CPU is normal. 100% isn't. So set an alert in grafana to ping/text you when your node hits 95% CPU. Set alerts to detect when /dev/nvme0n1p1 (the ledger partition) is at 90%+ allocation. 


**What is the deal with all these system optimizations and can I play around with the?**

Tech:
Edit system ops in `/etc/sysctl.conf` 
There is a of room to expkore here. Share your findiings with the DAO!
	
Full:
The main purpose is to make sure TCP memory buffers (the little bits of virtual memory allocated to mainteing each TCP port) is allocated nicely. Solana opens a lot of TCP connection and in linux each connection is assigned two header files (inbound and outboudn) and so you need to tell the kernel it's ok allow for a LOT of these file maps. Solana Shadow RPCs run with giant swapfiles. You can handle RAM blooming (spikes) better if you have properly informed the kernel to use swap when needed. Swapiness at 1 and the kernel won't use swap, but at 60 it may consume too much swap. Other things include very minor tunes to memory handling.

**How do I better understand my regional network telemetry?**

Tech:
Run `traceroute [url or ip]`
Ping local validators or google DNS servers in your area and ping them.
Run a `traceroute ssc-dao.genesysgo.net` against ssc-dao.genesysgo.net and see how it responds to your location. you can google for DNS servers in your area and get a list of IPs to insert in the traceroute to play around with pings in your regions.


