#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-blast-$dtime/
cd /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-blast-$dtime/

mkdir blast
perl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/blast/script/main_blast_v2.pl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/blast/cm_option_adv /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta blast  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-blast-$dtime.log
perl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta blast


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-blast-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-blast-$dtime/blast/hs1.pdb" ]];then 
	printf "!!!!! Failed to run blast, check the installation </home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/blast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-blast-$dtime/blast/hs1.pdb\n\n"
fi
