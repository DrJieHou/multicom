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

mkdir -p $outputdir/hhsuite3

cd $outputdir

perl /storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite3/script/tm_hhsuite3_main.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite3/hhsuite3_option $fastafile hhsuite3  2>&1 | tee  hhsuite3.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhsuite3.log>\n\n"


if [[ ! -f "$outputdir/hhsuite3/hhsu1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite3, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite3/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhsuite3/hhsu1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
