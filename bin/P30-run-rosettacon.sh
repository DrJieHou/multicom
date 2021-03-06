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

mkdir -p $outputdir/rosettacon

cd $outputdir
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/rosettacon/script/tm_rosettacon_main.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/rosettacon/rosettacon_option $fastafile rosettacon  2>&1 | tee  rosettacon.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/rosettacon.log>\n\n"


if [[ ! -f "$outputdir/rosettacon/rocon1.pdb" ]];then 
	printf "!!!!! Failed to run rosettacon, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/rosettacon/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/rosettacon/rocon1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

