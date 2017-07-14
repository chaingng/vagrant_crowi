#!/bin/sh

# setup ndenv
git clone https://github.com/riywo/ndenv ~/.ndenv
echo 'export PATH="$HOME/.ndenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(ndenv init -)"' >> ~/.bash_profile

git clone https://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build
. ~/.bash_profile
ndenv install v6.11.1
ndenv global v6.11.1
ndenv rehash

# setup mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo service mongod start

# setup crowi
git clone https://github.com/crowi/crowi.git
cd crowi
npm i -D node-sass
npm install
npm run build
PASSWORD_SEED=20170222crowitest MONGO_URI=mongodb://localhost/crowi node app.js
