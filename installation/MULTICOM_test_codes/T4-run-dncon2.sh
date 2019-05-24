#!/bin/bash

dtime=$(date +%Y-%b-%d)


source /home/casp14/MULTICOM_TS/jie_test/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/jie_test/multicom/tools/boost_1_55_0/lib/:/home/casp14/MULTICOM_TS/jie_test/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH


mkdir -p /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-dncon2-$dtime/
cd /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-dncon2-$dtime/
/home/casp14/MULTICOM_TS/jie_test/multicom/tools/DNCON2/dncon2-v1.0.sh /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-dncon2-$dtime/  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-dncon2-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-dncon2-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-dncon2-$dtime/T0993s2.dncon2.rr" ]];then 
	printf "!!!!! Failed to run DNCON2, check the installation </home/casp14/MULTICOM_TS/jie_test/multicom/tools/DNCON2/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-dncon2-$dtime/T0993s2.dncon2.rr\n\n"
fi
