#!/bin/bash

if [ $# != 3 ]; then
	echo "$0 <target id> <fasta> <output-directory>"
	exit
fi

targetid=$1
fastafile=$2
outputdir=$3

mkdir -p $outputdir
cd $outputdir

if [[ "$fastafile" != /* ]]
then
   echo "Please provide absolute path for $fastafile"
   exit
fi

if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/hhpred

cd $outputdir

perl /home/test/jie_test/multicom/src/meta/hhpred/script/tm_hhpred_main.pl /home/test/jie_test/multicom/src/meta/hhpred/hhpred_option $fastafile hhpred  2>&1 | tee  hhpred.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhpred.log>\n\n"


if [[ ! -f "$outputdir/hhpred/hp1.pdb" ]];then 
	printf "!!!!! Failed to run hhpred, check the installation </home/test/jie_test/multicom/src/meta/hhpred/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhpred/hp1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi



