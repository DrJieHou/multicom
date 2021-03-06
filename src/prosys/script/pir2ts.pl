#!/usr/bin/perl -w
#################################################################
#Given MSA and atom files for templates, generate 
#tertiary structure for the target sequence using modeller.
#Input parameters: modeller path, atom file path, working dir, 
#	msa file, number of models
#Output: target.#.pdb files. 
#	and to standard output: the prediction state reports
#
#Author: Jianlin Cheng
#Date: 4/15/2005
#################################################################
##############standard Amino Acids (3 letter <-> 1 letter)#######################################
%amino=();
$amino{"ALA"} = 'A';
$amino{"CYS"} = 'C';
$amino{"ASP"} = 'D';
$amino{"GLU"} = 'E';
$amino{"PHE"} = 'F';
$amino{"GLY"} = 'G';
$amino{"HIS"} = 'H';
$amino{"ILE"} = 'I';
$amino{"LYS"} = 'K';
$amino{"LEU"} = 'L';
$amino{"MET"} = 'M';
$amino{"ASN"} = 'N';
$amino{"PRO"} = 'P';
$amino{"GLN"} = 'Q';
$amino{"ARG"} = 'R';
$amino{"SER"} = 'S';
$amino{"THR"} = 'T';
$amino{"VAL"} = 'V';
$amino{"TRP"} = 'W';
$amino{"TYR"} = 'Y';
###################################################################################################
#read sequence from atom file
sub get_seq_from_atom
{
	#assume the atom file exists
	my $file = $_[0];
	open(ATOM, $file) || die "can't read atom file: $file\n";
	my @atoms = <ATOM>;
	close ATOM; 
	my $prev = -1;
	my $seq = ""; 
	while (@atoms)
	{
		my $text = shift @atoms;
		if ($text =~ /^ATOM/)
		{
			#get aa name
			#get position
			my $res = substr($text, 17, 3); 
			$res = uc($res); 
			$res =~ s/\s+//g;
			my $pos = substr($text, 22, 4);

			#if 3-letter, convert it to 1-letter.
			if (length($res) == 3)
			{
				if (exists($amino{$res}) )
				{
					$res = $amino{$res}; 
				}
				else
				{
					$res = "X"; 
					print "$file: resudie is unknown, shouldn't happen.\n"; 
				}
			}
			if ($pos != $prev)
			{
				$seq .= $res; 
				$prev = $pos; 
			}
		}
	}
	return $seq; 
}

if (@ARGV != 5)
{
	die "need five parameters: modeller path, atom file dir, working dir, msa file, number of models to generate.\n"; 
}

$modeller_dir = shift @ARGV;
$atom_dir = shift @ARGV;
$work_dir = shift @ARGV;
$msa_file = shift @ARGV;
$model_num = shift @ARGV;
$modeller = "$modeller_dir/bin/mod7v7";

-f "$modeller" || die "can't find modeller program.\n"; 
-d $modeller_dir || die "can't find modeller dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $work_dir || die "can't find working dir.\n";
-f $msa_file || die "can't find msa file.\n";

if ($model_num < 1 || $model_num > 10)
{
	die "model number is out of range.\n"; 
}

#read msa file to get a list of templates and sequence and msa info.
open(MSA, $msa_file) || die "can't read msa file.\n";
@msa = <MSA>;
@prot_names = (); #name of protein codes
@atom_names = (); #name of atom files
@temp_start = (); #the start of the templates
@temp_end = (); #the end of the templates
@seqs = (); #sequences in msa.

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
#	print "working dir: $work_dir\n";
}

#msa_file is not in work_dir, copy it first
#if ( $msa_file !~ /^\.\// && $msa_file =~ /\//)
#change it to directly check if the file is in work dir.
if (! -f "$work_dir/$msa_file")
{
	#print "copy msa file to working dir: $work_dir\n";
	`cp $msa_file $work_dir`; 
}

chdir $work_dir; 

while (@msa)
{
	$line = shift @msa; 
	chomp $line; 
	if ($line =~ /^>P1;(\S+)$/)
	{
		$name = $1; 
		push @prot_names, $name; 

		$info = shift @msa; 
		chomp $info; 
		@fields = split(/:/, $info);
		$atom_file = $fields[1];
		#for the last target sequence, no atom file
		push @atom_names, $atom_file; 

		$start = $fields[2]; #might include space, doesn't matter.
		push @temp_start, $start; 

		$end = $fields[4]; 
		push @temp_end, $end; 

		$seq = shift @msa; 	

		#remove the enter
		chomp $seq; 

		#remove the last "*"
		chop $seq; 

		push @seqs, $seq; 
	}
}

#copy the atom files and verify the consistency between 
#the templates and atom file
$temp_num = @atom_names - 1; 
for ($i = 0; $i < $temp_num; $i++) 
{
	$name = $atom_names[$i]; 
	$src_name = "$atom_dir/" . $name . ".atom.gz";
	if (! -f $src_name)
	{
		`cd $cur_dir`; 
		die "can't find the source template file: $src_name\n"; 
	}
	#copy the file to here
	`cp $src_name .`; 
	#unzip it
	`gunzip $name.atom.gz`; 
	#change name
	`mv $name.atom $name.atm`; 

	#read sequence from atom file
	$atom_seq = &get_seq_from_atom("$name.atm"); 

	#check if the msa match with template
	$start = $temp_start[$i];
	$end = $temp_end[$i]; 
	$temp_seq = $seqs[$i]; 

	for ($j = 0; $j < length($temp_seq); $j++)
	{
		$char = substr($temp_seq, $j, 1); 
		if ($char ne "-")
		{
			if ($char ne substr($atom_seq, $start-1,1))
			{
				die "template sequence doesn't match with atom sequence:$name\n$atom_seq\n$temp_seq\n";
			}
			$start++; 
		}
	}
}

#generate modeller top script
open(TOP, ">model.top") || die "can't create model.top script.\n";

print TOP "INCLUDE                           # Include the predefined TOP routines\n"; 
print TOP "SET OUTPUT_CONTROL = 1 1 1 1 1    # uncomment to produce a large log file\n";
print TOP "SET ALNFILE  = \'$msa_file\'      # alignment filename\n";
#print the templates
print TOP "SET KNOWNS = ";
for ($i = 0; $i < $temp_num; $i++) 
{
	$name = $prot_names[$i]; 
	print TOP " \'$name\'"; 
}
print TOP " # codes of the templates\n";

$target_name = $prot_names[$temp_num]; 
print TOP "SET SEQUENCE = \'$target_name\'   # code of the target\n";
print TOP "SET ATOM_FILES_DIRECTORY = \'./\' # directories for input atom files\n";
print TOP "SET STARTING_MODEL= 1             # index of the first model\n";
print TOP "SET ENDING_MODEL  = $model_num    # index of the last model\n\n"; 
print TOP "CALL ROUTINE = \'model\'\n";
close TOP; 

#run the modeller
system("$modeller model.top"); 

#check the results (analyze the log file) and change the pdb file name

for ($i = 1; $i <= $model_num; $i++)
{
	if (-f "$target_name.B9999000$i.pdb")
	{
		`mv $target_name.B9999000$i.pdb $target_name.$i.pdb`;
		print "model $i is created:$target_name.$i.pdb\n";
	}
	else
	{
		print "model $i is not created. Errors happen.\n"; 
	}
}

#log file
open(LOG, "model.log") || die "can't open modeller log file.\n";

@log = <LOG>;
close LOG; 
$energy = 0; 
while (@log)
{
	$line = shift @log;
	if ( $line =~ /^Current energy\s+:\s*([\d\.]+)/ )
	{
		$energy = $1;	
		print "Current Energy of Model: $energy\n";
	}
}

#in future, we are going to rank the model using energy. 

#clear up the temporary files
#`rm *.atm`; 
chdir $cur_dir; 


