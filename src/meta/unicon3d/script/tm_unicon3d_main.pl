#!/usr/bin/perl -w

##########################################################################
#Run UniCon3D to generate ab initio models for protein
##########################################################################

if (@ARGV < 3)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;
$contact_file = shift @ARGV;; # optional

if(!defined($contact_file))
{
        $contact_file='None';
}

if(!(-d $work_dir))
{
	`mkdir $work_dir`;
}
#make sure work dir is a full path (abosulte path)
$cur_dir = `pwd`;
chomp $cur_dir; 
#change dir to work dir
if ($work_dir !~ /^\//)
{
	if ($work_dir =~ /^\.\/(.+)/)
	{
		$work_dir = $cur_dir . "/" . $1;
	}
	else
	{
		$work_dir = $cur_dir . "/" . $work_dir; 
	}
	print "working dir: $work_dir\n";
}
-d $work_dir || die "working dir doesn't exist.\n";

`cp $fasta_file $work_dir`; 
`cp $option_file $work_dir`; 
chdir $work_dir; 

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#read option file
$pos = rindex($option_file, "/");
if ($pos > 0)
{
	$option_file = substr($option_file, $pos+1); 
}
open(OPTION, $option_file) || die "can't read option file.\n";
$prosys_dir = "";
$tool_dir = "";
$final_model_number = 5; 
$output_prefix_name = ""; #raptorx main program

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^output_prefix_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$output_prefix_name = $value; 
	}

	if ($line =~ /^tool_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tool_dir = $value; 
	}

	if ($line =~ /^metapsicov_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$metapsicov_dir = $value; 
	}

	if ($line =~ /^SCRATCH_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$scratch_dir = $value; 
	}

	if ($line =~ /^final_model_number/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$final_model_number = $value; 
	}

	if ($line =~ /^decoy_model_number/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$decoy_model_number = $value; 
	}

}

#check the options
-d $prosys_dir || die "can't find script dir: $prosys_dir.\n"; 
-d $tool_dir || die "can't find $tool_dir.\n";
-d $metapsicov_dir || die "can't find $metapsicov_dir.\n";
-d $scratch_dir || die "can't find $scratch_dir.\n";
$final_model_number > 0 && $final_model_number <= 10 || die "model number is out of range.\n";
$decoy_model_number > 0 && $decoy_model_number <= 100 || die "model number is out of range.\n";


#check fast file format
open(FASTA, $fasta_file) || die "can't read fasta file.\n";
$name = <FASTA>;
chomp $name; 
$seq = <FASTA>;
chomp $seq;
close FASTA;
if ($name =~ /^>/)
{
	$name = substr($name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}

$query_length = length($seq);

if ($query_length > 400)
{
	die "The number of amino acids is too long (> 200 residues), stop running CONFOLD2.\n";
}


print "Generate models using UniCon3D...\n";
use Cwd 'abs_path';
$fasta_file = abs_path($fasta_file);
print("perl $tool_dir/run_Unicon3D_withdncon2.pl $name $fasta_file $option_file $work_dir $contact_file &> run_Unicon3D.log\n\n"); 
system("perl $tool_dir/run_Unicon3D_withdncon2.pl $name $fasta_file $option_file $work_dir $contact_file &> run_Unicon3D.log"); 



for ($i = 1; $i < $final_model_number; $i++)
{
	if (-f "${output_prefix_name}-$i.pdb")
	{
		print "Model ${output_prefix_name}-$i.pdb is generated.\n";
	}
}


print "UniCon3D prediction is done.\n";

