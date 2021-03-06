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

mkdir -p $outputdir/compass

cd $outputdir
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/compass/script/tm_compass_main_v2.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/compass/compass_option_hard $fastafile compass  2>&1 | tee  compass.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/compass.log>\n\n"


if [[ ! -f "$outputdir/compass/com1.pdb" ]];then 
	printf "!!!!! Failed to run compass, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/compass/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/compass/com1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi


