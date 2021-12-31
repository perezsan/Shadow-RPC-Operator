# shadow_monitoring
Docker Monitoring Stack for Shadow Operators

### Docker install for 20.04 taken from DigitalOcean - https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04

**Step 1 — Installing Docker**

The Docker installation package available in the official Ubuntu repository may not be the latest version. To ensure we get the latest version, we’ll install Docker from the official Docker repository. To do that, we’ll add a new package source, add the GPG key from Docker to ensure the downloads are valid, and then install the package.

First, update your existing list of packages:

```sudo apt update```
 
Next, install a few prerequisite packages which let apt use packages over HTTPS:

```sudo apt install apt-transport-https ca-certificates curl software-properties-common```
 
Then add the GPG key for the official Docker repository to your system:

```curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -```
 
Add the Docker repository to APT sources:

```sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"```
 
This will also update our package database with the Docker packages from the newly added repo.

Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:

```apt-cache policy docker-ce```
 
You’ll see output like this, although the version number for Docker may be different:
```
Output of apt-cache policy docker-ce
docker-ce:
  Installed: (none)
  Candidate: 5:19.03.9~3-0~ubuntu-focal
  Version table:
     5:19.03.9~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages
 ```
Notice that docker-ce is not installed, but the candidate for installation is from the Docker repository for Ubuntu 20.04 (focal).

Finally, install Docker:

```sudo apt install docker-ce```
 
Docker should now be installed, the daemon started, and the process enabled to start on boot. Check that it’s running:

```sudo systemctl status docker```
 
The output should be similar to the following, showing that the service is active and running:
```
Output
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2020-05-19 17:00:41 UTC; 17s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 24321 (dockerd)
      Tasks: 8
     Memory: 46.4M
     CGroup: /system.slice/docker.service
             └─24321 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
Installing Docker now gives you not just the Docker service (daemon) but also the docker command line utility, or the Docker client. We’ll explore how to use the docker command later in this tutorial.
```
**Step 2 — Executing the Docker Command Without Sudo (Optional)**

By default, the docker command can only be run the root user or by a user in the docker group, which is automatically created during Docker’s installation process. If you attempt to run the docker command without prefixing it with sudo or without being in the docker group, you’ll get an output like this:

Output
docker: Cannot connect to the Docker daemon. Is the docker daemon running on this host?.
See 'docker run --help'.
If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:

```sudo usermod -aG docker ${USER}```
 
To apply the new group membership, log out of the server and back in, or type the following:

```su - ${USER}```
 
You will be prompted to enter your user’s password to continue.

Confirm that your user is now added to the docker group by typing:
```
groups
 ```
 ```
Output
sammy sudo docker
```
If you need to add a user to the docker group that you’re not logged in as, declare that username explicitly using:

```sudo usermod -aG docker username```
 
**The rest of this article assumes you are running the docker command as a user in the docker group. If you choose not to, please prepend the commands with sudo.**

**Installing Docker Compose - Taken from DigitalOcean with GG edits to support current version- https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04**


**Step 1 — Installing Docker Compose**

To make sure we obtain the most updated stable version of Docker Compose, we’ll download this software from its official Github repository.

First, confirm the latest version available in their releases page. At the time of this writing, the most current stable version is 2.2.2.

The following command will download the 2.2.2 release and save the executable file at /usr/local/bin/docker-compose, which will make this software globally accessible as docker-compose:

```sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose```
 
Next, set the correct permissions so that the docker-compose command is executable:

```sudo chmod +x /usr/local/bin/docker-compose```
 
To verify that the installation was successful, you can run:

```docker-compose --version```
 
You’ll see output similar to this:
```
Output
docker-compose version v2.2.2
```


Clone the shadow_monitoring repository:

```git clone https://github.com/Shadowy-Super-Coder-DAO/Shadow-RPC-Operator.git```

or download the tar file and untar using:

```tar -xvf monitoring.tar.gz```

Enter Shadow Monitoring Folder
```cd ~/Shadow-RPC-Operator/shadow_monitoring```

Create a docker storage for Grafana so that its persistent during reboots:

```sudo docker volume create grafana-storage```

Run Docker Compose and turn up the monitoring

```sudo docker-compose up -d```

Connect to grafana by going to the IP of the server with port 3000:

```
Example:
http:1.2.3.4:3000
```
Login with default credentials

```admin/admin```

**Importing Prometheus as a dataset to Grafana**

Hover over the gear button on the left panel near the bottom of the column and click **Data Sources**.  Click **Add Data Source** in the upper right hand side.  Select **Prometheus** from the list (will most likely be near the top).  http://prometheus:9090 (the hostname prometheus will work because of the shadow docker-compose built docker network).  **ENSURE PORT IS 9090, NOT 9000**  Add and save at the bottom. 

Navigate on the left to the Dashboards button.  This looks like 4 squares stacked.  Click import in the upper right of this screen.  Under import via grafana.com, type:
```1860```
Once this loads, click import at the bottom.

You now have a full linux node dashboard for your server and should start to see your metrics populate the dashboard soon.  More dashboards from GG will be coming soon, so stay tuned!
