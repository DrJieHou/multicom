#!/bin/sh

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


if [ ! -d "$database_path/prc_db" ]; then
  mkdir $database_path/prc_db
fi


/storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/prc/make_prc_db.pl $database_path /storage/hpc/scratch/jh7x3/multicom/tools/sam3.5.x86_64-linux/ $database_path/prc_db/ prcdb.lib

