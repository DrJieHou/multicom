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

mkdir -p $outputdir/newblast

cd $outputdir
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/newblast/script/newblast.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/newblast/newblast_option $fastafile newblast  2>&1 | tee  newblast.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/newblast.log>\n\n"


if [[ ! -f "$outputdir/newblast/newblast1.pdb" ]];then 
	printf "!!!!! Failed to run newblast, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/newblast/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/newblast/newblast1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
