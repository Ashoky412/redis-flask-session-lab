
#!/bin/bash
sudo yum update -y
sudo yum groupinstall "Development Tools" -y
sudo yum install gcc make jemalloc-devel -y

cd /opt
curl -O https://download.redis.io/releases/redis-7.2.4.tar.gz
tar xzvf redis-7.2.4.tar.gz
cd redis-7.2.4
make MALLOC=libc

sudo ln -s /opt/redis-7.2.4/src/redis-server /usr/local/bin/redis-server
sudo ln -s /opt/redis-7.2.4/src/redis-cli /usr/local/bin/redis-cli

redis-server --daemonize yes
pip3 install flask flask-session redis

nohup python3 ~/app.py > ~/flask.log 2>&1 &
