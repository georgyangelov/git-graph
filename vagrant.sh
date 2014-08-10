#!/usr/bin/env bash

# Install ruby 2.1.1
apt-get -y update
apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev cmake pkg-config
cd /tmp
wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.gz
tar -xvzf ruby-2.1.1.tar.gz
cd ruby-2.1.1/
./configure --prefix=/usr/local
make
sudo make install

# Install bundler
gem install bundler

# Go to vagrant dir
cd /vagrant

bundle install
