#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_compass_hard/
cd /home/jh7x3/multicom/test_out/T1006_compass_hard/

mkdir compass

touch /home/jh7x3/multicom/test_out/T1006_compass_hard.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_compass_hard/compass/com1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/compass/script/tm_compass_main_v2.pl /home/jh7x3/multicom/src/meta/compass/compass_option_hard /home/jh7x3/multicom/examples/T1006.fasta compass  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_compass_hard.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_compass_hard.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_compass_hard/compass/com1.pdb" ]];then 
	printf "!!!!! Failed to run compass, check the installation </home/jh7x3/multicom/src/meta/compass/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_compass_hard/compass/com1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_compass_hard.running