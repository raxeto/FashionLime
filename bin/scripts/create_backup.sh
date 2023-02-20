#!/bin/bash

set -e

PASSWORD=$1
CURR_DATETIME=`date +"%y-%m-%d-%H-%M"`
DEST_DIR_PATH=`mktemp -d -t dressme_backup.XXXXXX`
DEST_DIR_NAME=`basename "$DEST_DIR_PATH"`
echo "Temporary dir is located at $DEST_DIR_PATH"

echo "Creating a snapshot of the DB"

SNAPSHOT_NAME="mysql_dump.sql"
if [[ `which mysqldump5` ]]; then
  mysqldump5 -u root -p"$PASSWORD" dressme_dev > "$SNAPSHOT_NAME"
else
  mysqldump -u root -p"$PASSWORD" dressme_dev > "$SNAPSHOT_NAME"
fi

mv $SNAPSHOT_NAME $DEST_DIR_PATH

echo "Copying the paperclip images"

cp -rf "public/system" "$DEST_DIR_PATH"

echo "Archiving"

ARCHIVE_NAME="backup-$CURR_DATETIME.zip"

pushd "$DEST_DIR_PATH/.."
  ARCHIVE_DIR=`pwd`
  zip -r -m $ARCHIVE_NAME "./$DEST_DIR_NAME"
popd

mkdir -p "db/backups/"
mv "$ARCHIVE_DIR/$ARCHIVE_NAME" "db/backups/"

echo "Done. File saved in db/backups/$ARCHIVE_NAME"
