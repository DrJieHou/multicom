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

mkdir -p $outputdir/csiblast

cd $outputdir
perl /storage/hpc/scratch/jh7x3/multicom/src/meta/csblast/script/multicom_csiblast_v2.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/csblast/csiblast_option $fastafile csiblast  2>&1 | tee  csiblast.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/csiblast.log>\n\n"


if [[ ! -f "$outputdir/csiblast/csiblast1.pdb" ]];then 
	printf "!!!!! Failed to run blast, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/blast/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/csiblast/csiblast1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

