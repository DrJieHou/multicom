#!/bin/sh

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


if [ ! -d "$database_path/hhsearch1.5_db/" ]; then
  mkdir $database_path/hhsearch1.5_db/
fi


/home/jhou4/tools/multicom/src/update_db/tools/hhsearch1.5/make_hhsearch15_db.pl /home/jhou4/tools/multicom/src/update_db/tools/hhsearch1.5/ $database_path /home/jhou4/tools/multicom/tools/hhsearch1.5.0/ $database_path/hhsearch1.5_db hhsearch15db 

