# Set up python venv using python 3.6
python3.6 -m venv env
source env/bin/activate
pip install -r requirements.txt

# Set up configs
python parse_config.py

# Set up certificates
openssl genrsa -out ssl_pem/ca-key.pem 4096
openssl req -new -x509 -sha256 -days 365 -key ssl_pem/ca-key.pem -out ca.pem
openssl genrsa -out ssl_pem/cert-key.pem 4096
openssl req -new -sha256 -subj "/CN=yourcn" -key ssl_pem/cert-key.pem -out ssl_pem/cert.csr
openssl x509 -req -sha256 -days 365 -in ssl_pem/cert.csr -CA ssl_pem/ca.pem -CAkey ssl_pem/ca-key.pem -out ssl_pem/cert.pem -extfile ssl_pem/extfile.conf -CAcreateserial

# Set up docker containers
docker run -v ./configs/OME_conf/Server.xml:/opt/ovenmediaengine/bin/origin_conf/Server.xml -v ./ssl_pem:/etc/cert -p 3333:3333 -p 3334:3334 -p 3478:3478 -p 8081:8081 -p 8082:8082 -p 10000-10010:10000-10010/udp --name OME -d airensoft/ovenmediaengine:dev
docker run -v ./configs/nginx_conf/nginx.conf:/etc/nginx/conf.d/default.conf -v ./ssl_pem:/etc/nginx/cert -p 7777:80 -p 7778:443 --name Nginx -d nginx
docker run -v ./configs/grafana_conf/grafana.ini:/etc/grafana/grafana.ini -v ./ssl_pem:/etc/grafana/cert -p 3000:3000 --name Grafana -d grafana/grafana-enterprise
