#!/bin/bash

CURR_DATE=`date +"%Y-%m-%d" -d "yesterday"`
echo "Updating the GA data for data $CURR_DATE..."

pushd $HOME/repos/project
        . $HOME/.profile
        bundle exec rake ga:get_data[$CURR_DATE]
popd

echo "Done"