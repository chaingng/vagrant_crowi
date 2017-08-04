#!/bin/sh

# install git
if ! type "git" > /dev/null 2>&1
then
  sudo apt-get -y install git
fi

# setup ndenv
if ! type "ndenv" > /dev/null 2>&1
then
  git clone https://github.com/riywo/ndenv ~/.ndenv
  echo 'export PATH="$HOME/.ndenv/bin:$PATH"' >> ~/.bash_profile
  echo 'eval "$(ndenv init -)"' >> ~/.bash_profile

  git clone https://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build
  . ~/.bash_profile
  ndenv install v6.11.1
  ndenv global v6.11.1
  ndenv rehash
fi


# setup mongodb
if ! type "mongod" > /dev/null 2>&1
then
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
  echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org
fi

# create mongodb deamon script
sudo cat << EOS | sudo tee /etc/systemd/system/mongod.service
[Unit]
Description=MongoDB Database Service
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/bin/mongod --config /etc/mongod.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
User=mongodb
Group=mongodb
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOS

sudo service mongod start
sudo systemctl enable mongod

if ! type "elasticsearch" > /dev/null 2>&1
then
  apt-get install -y openjdk-8-jdk
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  sudo apt-get install -y apt-transport-https
  echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
  sudo apt-get update
  sudo apt-get install -y elasticsearch
  sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-kuromoji
  sudo /bin/systemctl daemon-reload
  sudo /bin/systemctl enable elasticsearch.service
  sudo systemctl start elasticsearch.service
  echo 'ELASTICSEARCH_URI="localhost:9200"' >> ~/.bash_profile
fi

# setup crowi
sudo apt-get install -y libkrb5-dev
git clone https://github.com/crowi/crowi.git
cd crowi
npm i -D node-sass
npm install
npm run build

echo 'PASSWORD_SEED=20170222crowitest' >> ~/.bash_profile
echo 'MONGO_URI=mongodb://localhost/crowi' >> ~/.bash_profile
. ~/.bash_profile

node app.js
