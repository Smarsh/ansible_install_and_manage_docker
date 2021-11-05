#!/bin/bash

# install build dependencies
sudo yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel

# clone and install rbenv environment
cd ~
git clone git://github.com/sstephenson/rbenv.git .rbenv
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# re-init bash
source ~/.bash_profile

# install latest ruby
rbenv install -v 2.2.2

# sets the default ruby version that the shell will use
rbenv global 2.2.2

# to disable generating of documents as that would take so much time
echo "gem: --no-document" > ~/.gemrc

# install bundler
gem install bundler

# must be executed everytime a gem has been installed in order for the ruby executable to run
rbenv rehash