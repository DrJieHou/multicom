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

mkdir -p $outputdir/hhsuite

cd $outputdir
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite/script/tm_hhsuite_main.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite/hhsuite_option $fastafile hhsuite  2>&1 | tee hhsuite.log
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite/script/tm_hhsuite_main_simple.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite/super_option $fastafile hhsuite
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite/script/filter_identical_hhsuite.pl hhsuite


printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhsuite.log>\n\n"


if [[ ! -f "$outputdir/hhsuite/hhsuite1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/hhsuite/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhsuite/hhsuite1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

