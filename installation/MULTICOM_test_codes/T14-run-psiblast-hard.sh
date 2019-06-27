#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_psiblast_hard/
cd /home/jh7x3/multicom/test_out/T1006_psiblast_hard/

mkdir psiblast
touch /home/jh7x3/multicom/test_out/T1006_psiblast_hard.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_psiblast_hard/psiblast/psiblast1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/psiblast/script/main_psiblast_v2.pl /home/jh7x3/multicom/src/meta/psiblast/psiblast_option_hard /home/jh7x3/multicom/examples/T1006.fasta psiblast  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_psiblast_hard.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_psiblast_hard.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_psiblast_hard/psiblast/psiblast1.pdb" ]];then 
	printf "!!!!! Failed to run psiblast, check the installation </home/jh7x3/multicom/src/meta/psiblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_psiblast_hard/psiblast/psiblast1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_psiblast_hard.running