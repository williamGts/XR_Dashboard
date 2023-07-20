# XR Dashboard
## Introduction
This is a web server that displays the status of XR devices. It is designed to be used with Prometheus and Grafana.

## Prerequisits
1. Python 3.6
2. OpenSSL
3. Docker

## Install and Initialize
1. Clone this repository
   ```
   $ git clone https://github.com/Shutoparu/XR_Dashboard/.git
   ```
2. In [ip.txt](./ip.txt), set hostname and ip address. Remeber to add a space after colon.
3. Set up exporter. (Will be explained in future)
4. Manually config prometheus to scrape exporter in [prometheus.yml](./configs/prometheus_conf/prometheus.yml)
5. Run [init.sh](./init.sh) to set up environment. (Only need to run once)
   ```
   $ ./init.sh
   ```
6. Run [run.sh] to boot up web server. To stop, send an interrupt signal to the process.
   ```
   $ ./run.sh
   ```
7.  Add the generated CA to trusted CA list in your browser. [method](https://blog.miniasp.com/post/2019/02/25/Creating-Self-signed-Certificate-using-OpenSSL)
8.  You should see the web server running on https://your.ip.address:5000