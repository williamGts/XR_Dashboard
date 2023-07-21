# XR Dashboard
## Introduction
This is a web server that displays the status of XR devices. It is designed to be used with Prometheus and Grafana.
The webpage is based on open source project [OvenSpace](https://github.com/airensoft/ovenspace).

## Prerequisits
1. Python 3.6
2. OpenSSL
3. Docker

## Install and Initialize
1. Clone this repository
   ```
   $ git clone https://github.com/Shutoparu/XR_Dashboard.git
   ```
2. In [ip.txt](./ip.txt), set hostname and ip address. Remeber to add a space after colon.
3. [Set up exporters](#set-up-exporters).
4. [Configure Prometheus](#configure-prometheus).
5. Run [init.sh](./init.sh) to set up environment. Fill in necessary information. (Only need to run once)
   ```
   $ ./init.sh
   ```
6. [Create Grafana panels](#configure-grafana-panels).
7. Run [run.sh] to boot up web server. To stop, send an interrupt signal to the process.
   ```
   $ ./run.sh
   ```
8.  Add the generated CA to trusted CA list to your browser. [method1](https://blog.miniasp.com/post/2019/02/25/Creating-Self-signed-Certificate-using-OpenSSL) [method2](https://github.com/ChristianLempa/cheat-sheets/blob/main/misc/ssl-certs.md)
9.  You should see the web server running on https://your.ip.address:5000

### To change IP address and/or host name:
1. Change [ip.txt](./ip.txt)
2. run [update_ip.sh](./update_ip.sh)
   ```
   $ ./update_ip.sh
   ```
3. Restart web server
   ```
   $ ./run.sh
   ```
## Set up Exporters

## Configure Prometheus

## Create Grafana Panels