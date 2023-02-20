#!/bin/bash

set -x
set -e

echo "Setting up the deployment environment. If an error occurs, manually fix the cause of it and continue executing commands from the script from the point where you left off"

echo "Installing rbenv"
cd
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "Installing MRI ruby 2.2.3"
rbenv install 2.2.3
rbenv global 2.2.3

# echo "Installing rbx-3.69"
# rbenv install rbx-3.69
# rbenv global rbx-3.69

echo "gem: --no-document" > ~/.gemrc
gem install bundler

echo "Git setup"
git config --global pack.window "0"
git config --global pack.windowMemory "100m"
git config --global pack.packSizeLimit "100m"
git config --global pack.threads "1"

# Now is a good time to run the following fixtures (and probably more have been introduced lately)
# colors
# location_types
# occasions
# outfit_categories
# payment_types
# product_categories
# seasons
# size_categories
# size_descriptors
# user_roles
# size_category_descriptors