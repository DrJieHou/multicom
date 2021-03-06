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

mkdir -p $outputdir/hmmer

cd $outputdir
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/hmmer/hmmer_option $fastafile hmmer  2>&1 | tee  hmmer.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/hmmer.log>\n\n"


if [[ ! -f "$outputdir/hmmer/hmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/hmmer/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hmmer/hmmer1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

