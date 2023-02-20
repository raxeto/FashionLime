#!/bin/bash

set -e

BACKUP_NAME=$1

pushd "db/backups"

  if [[ -z "$1" ]]; then
    BACKUP_NAME=`ls -v | tail -1`
    echo "Using the latest backup $BACKUP_NAME"
  fi

  unzip -q $BACKUP_NAME

  BACKUP_DIR_NAME=""
  for f in *; do
    if [[ -d $f ]]; then
        BACKUP_DIR_NAME="$f"
        break
    fi
  done

  pushd $BACKUP_DIR_NAME
    echo "Dropping the current DB"

    bundle exec rake db:drop db:create db:migrate db:fixtures:load RAILS_ENV=development

    echo "Loading the data from the snapshot"

    if [[ `which mysql5` ]]; then
      mysql5 -u root -p dressme_dev < mysql_dump.sql
    else
      mysql -u root -p dressme_dev < mysql_dump.sql
    fi

    echo "success: $?"

    echo "Syncing the images with the DB data"

    rm -rf "../../../public/system"
    mv "system" "../../../public/system"

  popd

  rm -rf "$BACKUP_DIR_NAME"

popd

echo "Done."
