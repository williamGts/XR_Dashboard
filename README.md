# XR Dashboard
## Introduction
This is a web server that displays the status of XR devices. It is designed to be used with Prometheus and Grafana.
The webpage is based on open source project [OvenSpace](https://github.com/airensoft/ovenspace).

## Prerequisits
1. [Python 3.6](https://www.python.org/downloads/release/python-368/)
2. [OpenSSL](https://slproweb.com/products/Win32OpenSSL.html)
3. [Docker](https://www.docker.com/products/docker-desktop/)

## Before starting

1.  All the shell scripts you see below has a corresponding powershell script for windows. If you are using windows, use the powershell script instead. (e.g. `init.sh` -> `init.ps1`)
2. Make sure script execution on Powershell is enabled on central server. If not, run the following line in powershell to enable script executing:
   ```
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
   ```
3. For Windows, we assume you have set up alias for both python3.6 and openssl. In the following scripts, we use the names `python36` and `openssl`. If you don't have the alias set up, please refer to [this](#set-up-alias-for-python-and-openssl-on-windows).

## Install and Initialize Central Server

1. Clone this repository
   ```
   $ git clone https://github.com/Shutoparu/XR_Dashboard.git
   ```
2. In `config.cfg`, set hostname and ip address. For example:
   ```
   [HOST.IP]
   dns_hostname = your_hostname
   ip_address = your.host.ip.address
   ```
3. [Set up exporters](#set-up-exporters-on-edge-servers) and [configure Prometheus](#configure-prometheus).
4. Run `init.sh` to set up environment. Fill in necessary information. (Only need to run once)
   ```
   $ ./init.sh
   ```
   What the script does (in order):
   - Create a Python 3.6 virtual environment
   - Install required packages
   - Create config files for Grafana, Prometheus, Nginx, XR Dashboard and SSL certificate.
   - Generate a Self signed CA certificate, if not yet created.
     - OpenSSL will prompt you to fill in the following information. Here is an example of what you should fill in:
       - Country Name (2 letter code) [AU]: TW
       - State or Province Name (full name) [Some-State]: Taiwan
       - Locality Name (eg, city) []: Taipei
       - Organization Name (eg, company) [Internet Widgits Pty Ltd]: Compal Electronics, Inc.
       - Organizational Unit name (eg, section) []: XR_Cube
       - Common Name (e.g. server FQDN or YOUR name) []: XR_Cube
       - Email Address []: your.email@email.com
     - If you already have a CA certificate, put it in `ssl_pem` folder and name it `ca.pem` before running `init.sh`. Also, put the corresponding private key in `ssl_pem` folder and name it `ca-key.pem`.
   - Generate a Self signed SSL certificate for development based with the given IP address.
   - Initialize docker containers for Grafana, Prometheus, Nginx, and OvenMediaEngine, if they are not yet initialized.
5.  Add the generated CA to trusted CA list to your machine. [How to add CA to trusted CA list](#add-ca-to-trusted-ca-list).
6. [Set up Grafana](#set-up-grafana).
7. Run `run.sh` to boot up web server. To stop, run `stop.sh`
   ```
   $ ./run.sh
   $ ./stop.sh
   ```
   - The script uses gunicorn to put the process in background. stdout and stderr will be redirected to `OvenSpace.log`
8. You should see the web server running on `https://your.host.ip.address:7778`

### After making any changes to the `config.cfg` after initialization
1. Run `update.sh`
   ```
   $ ./update.sh
   ```
   - The script will update all IP and hostname related section in all config files, and restart all docker containers.
2. Restart web server with `run.sh`
   ```
   $ ./run.sh
   ```

---
## How to use

### To Monitor
Visit `https://your.host.ip.address:7778` to access the web server. You should see a page where you can monitor multiple panels.
On the navigate bar on the right, you can see the following list:
- Overview: This the page you are currently in (default landing page).
- Monitor: This page allows you to monitor the screen of all edge servers at once.
- Edge 1~8: This is the list of devices you are monitoring. Click on the device name to switch to that device's panel.

### To Register as monitor target
Before starting, make sure your edge device is connected to the same network as the central server. Also, make sure you have set up exporters on the edge device (see [Set up exporters](#set-up-exporters-on-edge-servers)), and the edge device trusts your CA (see [Add CA to trusted CA list](#add-ca-to-trusted-ca-list)). You will need to copy the exact same `ca.pem` generated during initialization to the edge device.

Visit `https://your.host.ip.address:7778/register` on your edge device. You should see a page where you can register your device. Hit on the `Register` button and follow the guide.

---

## Set up exporters (On edge servers)

Below are the three exporters we use:

- [Nvidia Gpu Exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter)
    - Default port: 9835
  
- [Ping Exporter](https://github.com/2767321434/ping_exporter)
    - Default port: 8888

- [Windows Exporter](https://github.com/prometheus-community/windows_exporter)
    - Default port: 9182

To set up, copy the `Exporter` folder to the edge servers and run `start_exporter.bat` in the folder.
The script will prompt you to put an IP or DNS to ping. (Need to modify the script for automatic connection with client.)

## Configure Prometheus

###### Make sure to configure Prometheus before running `init.sh`. If config is changed after the Prometheus Docker container is run, make sure to restart the container.

To configure Prometheus, if you are using the default config, you only need to change the `config.cfg` file.

```conf
# Edge information
[EDGE.IP]
edge_1 = 192.168.3.47
edge_2 = 192.168.3.48
edge_3 = 192.168.3.49
edge_4 = 192.168.3.50
edge_5 = 192.168.3.51
edge_6 = 192.168.3.52
edge_7 = 192.168.3.53
edge_8 = 192.168.3.54

# Edge scraping port
[EDGE.SCRAPE.PORT]
windows_exporter = 9182
NVIDIA_exporter = 9835
ping_exporter = 8888
```

Change the IP addresses and ports to the ones you are using. If default ports are used, you can leave it as it is.

After changing the config, and `init.sh` is run (or `update.sh` is run), you should see the following in `configs/prometheus_conf/prometheus.yml`:
    
```yml
global: # global config, not related to scraping targets
  evaluation_interval: 15s
  scrape_interval: 15s

rule_files: null # add more rule files here if needed
  # - "first.rules"
  # - "second.rules"

scrape_configs: # add scrape jobs here
- job_name: prometheus
  static_configs:
  - targets:
    - localhost:9090
- job_name: NVIDIA1
  static_configs:
  - targets:
    - 192.168.3.47:9835
- job_name: windows_exporter1
  static_configs:
  - targets:
    - 192.168.3.47:9182
- job_name: ping_exporter1
  static_configs:
  - targets:
    - 192.168.3.47:8888
# more jobs can be added.

```

Also, you should see it running on `http://your.host.ip.address:9090`
To check if the exporters are working, go to `http://your.host.ip.address:9090/targets`. You should see all the exporters you configured in the `prometheus.yml` file. If you see `DOWN` in the `State` column, it means the exporter is not working. Check the exporter's log to see what went wrong.

---

## Add CA to trusted CA list
- Windows: 
  1. Open `certmgr.msc` with run ( Win+R ).
  2. Right click on `Trusted Root Certification Authorities` -> `All Tasks` -> `Import...`
  3. Locate and import the generated CA certificate `ca.pem`. (You might need to select "See all files" in the file selection dialog")
  4. Click `Next` and `Finish`.

- Android: (The exact steps vary device-to-device, but here is a generalised guide:)

  1. Open Phone Settings
  2. Locate Encryption and Credentials section. It is generally found under Settings > Security > Encryption and Credentials
  3. Choose Install a certificate
  4. Choose CA Certificate
  5. Locate the certificate file ca.pem on your SD Card/Internal Storage using the file manager.
  6. Select to load it.
  7. Done!

- MacOS:
  run the following script:
  ```
  $ sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /path/to/ca.pem
  ```

---

## Set up Grafana

Make sure the `init.sh` script is run. If config is changed after the Grafana Docker container is run, make sure to restart the container.

### Access Grafana
Visit `https://your.host.ip.address:3000` to access Grafana. 

Click Sign in on top right of the screen. Log in with the default username and password `admin`. You will be asked to change your password after logging in for the first time (skip recommended).
 
### Add data source
    
1. Open the navigation panel on top left of the screen (three stripes).
2. Click `Connection -> Add new connection` and search for `Prometheus`.
3. Click on `Prometheus` and click `Create a Prometheus data source`.
4. Give the data source a name, e.g. `Prometheus_XR`.
5. In the `Prometheus server URL` section, enter `http://host.docker.internal:9090` and hit `Save & Test`.

### Import Dashboard

1. Click the `+` button on top right of the page -> `Import Dashboard`
2. Upload `XR_CUBE.json` to the page.
3. Select the newly created Prometheus data source (e.g. `Prometheus_XR`) and click `Import`.

---

## Set up alias for python and openssl on windows
Here, we provide two methods for you to choose from.
##### 1. Create a file named `profile.ps1` to be run everytime when powersehll is run
1. Open powershell as admin
2. Create a file named `profile.ps1` in `$Home\Documents\WindowsPowerShell`. This will only affect the current user.
   ```
   $ New-Item -Path $Home\Documents\WindowsPowerShell -Name profile.ps1 -ItemType file
   ```
   Or create a file named `profile.ps1` in `$PsHome` if you want to affect all users.
   ```
    $ New-Item -Path $PsHome -Name profile.ps1 -ItemType file
    ```

3. Open the file with notepad
   ```
    $ notepad $Home\Documents\WindowsPowerShell\profile.ps1
    ```
    or
    ```
    $ notepad $PsHome\profile.ps1
    ```
4. Add the following lines to the file
   ```
   sal -Name python36 -Value path/to/python3.6.exe
   sal -Name openssl -Value path/to/openssl.exe
   ```
5. Save and close the file
6. Restart powershell
   
##### 2. Uncomment the following lines in `init.ps1` and `.\misc\generate_cert.ps1` run it as admin
   1. Open powershell as admin
   2. Uncomment and modify the following lines in `init.ps1`
      ```
      sal -Name python36 -Value path/to/python3.6.exe
      sal -Name openssl -Value path/to/openssl.exe
      ```
   3. Uncomment and modify the following line in `.\misc\generate_cert.ps1`
      ```
      sal -Name openssl -Value path/to/openssl.exe
      ```
      