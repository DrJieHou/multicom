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

mkdir -p $outputdir/hmmer3

cd $outputdir
perl /home/jhou4/tools/multicom/src/meta/hmmer3/script/tm_hmmer3_main.pl /home/jhou4/tools/multicom/src/meta/hmmer3/hmmer3_option $fastafile hmmer3  2>&1 | tee  hmmer3.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/hmmer3.log>\n\n"


if [[ ! -f "$outputdir/hmmer3/jackhmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer3, check the installation </home/jhou4/tools/multicom/src/meta/hmmer3/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hmmer3/jackhmmer1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

