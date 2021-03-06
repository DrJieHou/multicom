#!/usr/bin/perl -w

##########################################################################
#The main script of template-based modeling using compass and combinations
#Inputs: option file, fasta file, output dir.
#Outputs: compass output file, local alignment file, combined pir msa file,
#         pdb file (if available, and log file)
#Author: Jianlin Cheng
#Modifided from tm_hhsearch_join.pl
#Date: 12/29/2007
##########################################################################

if (@ARGV != 3)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;

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
$blast_dir = "";
$modeller_dir = "";
$pdb_db_dir = "";
$nr_dir = "";
$atom_dir = "";
$hhsearch_dir = "";
$hhsearchdb = "";
$compass_dir = "";
$compassdb = "";
$psipred_dir = "";
#initialized with default values
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 20;
$cm_min_cover_size = 20;

$cm_comb_method = "new_comb";
$cm_model_num = 5; 

$cm_max_linker_size=10;
$cm_evalue_comb=0;

$adv_comb_join_max_size = -1; 

#options for sorting local alignments
$sort_blast_align = "no";
$sort_blast_local_ratio = 2;
$sort_blast_local_delta_resolution = 2;
$add_stx_info_rm_identical = "no";
$rm_identical_resolution = 2;

$cm_clean_redundant_align = "no";

$cm_evalue_diff = 1000; 

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^script_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$script_dir = $value; 
	#	print "$script_dir\n";
	}

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
		$script_dir = "$prosys_dir/script";
	#	print "$script_dir\n";
	}

	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}
	if ($line =~ /^modeller_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_dir = $value; 
	}
	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}
	if ($line =~ /^nr_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_dir = $value; 
	}
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^hhsearch_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch_dir = $value; 
	}

	if ($line =~ /^compass_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$compass_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^psipred_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psipred_dir = $value; 
	}

	if ($line =~ /^hhsearchdb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearchdb = $value; 
	}

	if ($line =~ /^compassdb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$compassdb = $value; 
	}

	if ($line =~ /^cm_blast_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_blast_evalue = $value; 
	}
	if ($line =~ /^cm_align_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_align_evalue = $value; 
	}
	if ($line =~ /^cm_max_gap_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_gap_size = $value; 
	}
	if ($line =~ /^cm_min_cover_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_min_cover_size = $value; 
	}
	if ($line =~ /^cm_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_model_num = $value; 
	}

	if ($line =~ /^cm_max_linker_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_linker_size = $value; 
	}

	if ($line =~ /^cm_evalue_comb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_comb = $value; 
	}

	if ($line =~ /^cm_comb_method/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_comb_method = $value; 
	}

	if ($line =~ /^adv_comb_join_max_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$adv_comb_join_max_size = $value; 
	}

	if ($line =~ /^chain_stx_info/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$chain_stx_info = $value; 
	}

	if ($line =~ /^sort_blast_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_align = $value; 
	}

	if ($line =~ /^sort_blast_local_ratio/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_ratio = $value; 
	}

	if ($line =~ /^sort_blast_local_delta_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_delta_resolution = $value; 
	}

	if ($line =~ /^add_stx_info_rm_identical/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$add_stx_info_rm_identical = $value; 
	}

	if ($line =~ /^rm_identical_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rm_identical_resolution = $value; 
	}

	if ($line =~ /^cm_clean_redundant_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_clean_redundant_align = $value; 
	}

	if ($line =~ /^cm_evalue_diff/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_diff = $value; 
	}
	if ($line =~ /^nr_iteration_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_iteration_num = $value; 
	}
	if ($line =~ /^nr_return_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_return_evalue = $value; 
	}
	if ($line =~ /^nr_including_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_including_evalue = $value; 
	}

}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
-d $hhsearch_dir || die "can't find hhsearch dir.\n";
-d $compass_dir || die "can't find compass dir.\n";
-d $psipred_dir || die "can't find psipred dir.\n"; 
-f "${compassdb}1" || die "can't find compass database 1.\n";
-f "${compassdb}2" || die "can't find compass database 2.\n";
-d $nr_dir || die "can't find nr dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";

if ($cm_blast_evalue <= 0 || $cm_blast_evalue >= 10 || $cm_align_evalue <= 0 || $cm_align_evalue >= 10)
{
	die "blast evalue or align evalue is out of range (0,10).\n"; 
}
#if ($cm_max_gap_size <= 0 || $cm_min_cover_size <= 0)
if ($cm_min_cover_size <= 0)
{
	die "max gap size or min cover size is non-positive. stop.\n"; 
}
if ($cm_model_num < 1)
{
	die "model number should be bigger than 0.\n"; 
}

if ($cm_evalue_comb > 0)
{
#	die "the evalue threshold for alignment combination must be <= 0.\n";
}

if ($sort_blast_align eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
	}
}

if ($add_stx_info_rm_identical eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't add structural information to alignments.\n";
		$add_stx_info_rm_identical = "no";
	}
}

if ($sort_blast_local_ratio <= 1 || $sort_blast_local_delta_resolution <= 0)
{
		warn "sort_blast_local_ratio <= 1 or delta resolution <= 0. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
}
if ($rm_identical_resolution <= 0)
{
	warn "rm_identical_resolution <= 0. Don't add structure information and remove identical alignments.\n";
	$add_stx_info_rm_identical = "no";
}

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

################################################################
#blast protein and nr(if necessary) to find homology templates.
#assumption: pdb database name is: pdb_cm
#	     nr database name is: nr
#################################################################
$nr_db = "$nr_dir/nr";
print "blast NR to find homology templates...\n";
(-f "$nr_dir/nr.phr" || -f "$nr_dir/nr.pal") || die "can't find the nr database.\n"; 

#generate input profile
#print("$blast_dir/blastpgp -i $fasta_file -o $fasta_file.blast -j $nr_iteration_num -e $nr_return_evalue -h $nr_including_evalue -d $nr_db"); 
system("$blast_dir/blastpgp -i $fasta_file -o $fasta_file.blast -j $nr_iteration_num -e $nr_return_evalue -h $nr_including_evalue -d $nr_db"); 


#get file name prefix
$idx = rindex($fasta_file, ".");
if ($idx > 0)
{
	$filename = substr($fasta_file, 0, $idx);
}
else
{
	$filename = $fasta_file; 
}

#convert blast output to raw alignment
print "convert blast output to alignment...\n"; 
system("$prosys_dir/script/process-blast.pl $fasta_file.blast $name.align $fasta_file");

#convert alignment file to aln format
system("$prosys_dir/script/generate_aln_new.pl $prosys_dir/script . $fasta_file $work_dir $work_dir");

-f "$work_dir/$name.aln" || die "alignment file is not generated.\n";

#futher refine aln file
system("$compass_dir/compass_search/prep_psiblastali -i $work_dir/$name.aln -o $work_dir/$name.paln");


########################Search two compass databases###################################################

@indices = (1, 2); 
@rank = ();
while (@indices)
{

$index = shift @indices;

#search the profile against compass database
print "search the profile against compass database $index...\n";
system("$compass_dir/compass_search/compass_vs_db -e 1 -i $name.paln -d $compassdb$index -o $name.com$index");

if (! -f "$name.com$index")
{
	warn "no template is found in $compassdb$index\n";
	next;
}

#get all selected templates
open(COM, "$name.com$index") || die "No templates are found.\n";
@com = <COM>;
close COM;

while (@com)
{
	$line = shift @com;
	if ($line =~ /^Profiles producing significant alignments:/ )
	{
		$idx = 0;
	#	@rank = ();
		
		while (@com)
		{
			$line = shift @com;
			if ($line eq "\n")
			{
				last;
			}	
			chomp $line;
			($path, $score, $evalue) = split(/\s+/, $line);
			$score = 0;

			if ($path =~ /^\//)
			{
				$idx++;
				#get template id
				$pos = rindex($path, "/");
				$tname = substr($path, $pos+1, 5);
				push @rank, "$idx\t$tname\t$evalue";
			}
		}

	}

}

	#parse the blast output
	print "parse compass output...\n"; 
	system("$meta_dir/script/parse_compass.pl $name.com$index $fasta_file.local$index");

	if (! -f "$fasta_file.local$index")
	{
		next;
	}

	#get all local aignments
	open(LOCAL, "$fasta_file.local$index") || die "can't read the parsed output results.\n"; 
	@tlocal = <LOCAL>;
	close LOCAL;
	if (@tlocal <= 2)
	{
		warn "no significant templates are found. stop.\n";
		next;
	}

	shift @tlocal; shift @tlocal;
	push @local, @tlocal;
	push @local, "\n"; 
}

@local % 5 == 0 || die "number of local alignments is not right.\n";

@rlocal = ();
while (@local)
{
	$line = shift @local;
	$line .= (shift @local);
	$line .= (shift @local);
	$line .= (shift @local);
	shift @local;
	push @rlocal, $line;
}

#now, combine ranking and local alignments

#re-rank all templates
#different format: 0.####, e-####, #e-#### 
#return: -1: less, 0: equal, 1: more
sub comp_evalue
{
	my ($a, $b) = @_;
	#get format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		$formata = "num";
	}
	elsif ($a =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formata = "exp";
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
	#	if ($a_next > 0)
#		{
	#		die "exponent must be negative or 0: $a\n"; 
#		}
	}
	else
	{
		die "evalue format error: $a";	
	}

	if ( $b =~ /^[\d\.]+$/ )
	{
		$formatb = "num";
	}
	elsif ($b =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formatb = "exp";
		$b_prev = $1;
		$b_next = $2;  
		if ($1 eq "")
		{
			$b_prev = 1; 
		}
	#	if ($b_next > 0)
	#	{
	#		die "exponent must be negative or 0: $b\n"; 
	#	}
	}
	else
	{
		die "evalue format error: $b";	
	}
	if ($formata eq "num")
	{
		if ($formatb eq "num")
		{
			return $a <=> $b
		}
		else  #bug here
		{
			#a is bigger
			#return 1; 	
			#return $a <=> $b_prev * (10**$b_next); 
			return $a <=> $b_prev * (2.72**$b_next); 
		}
	}
	else
	{
		if ($formatb eq "num")
		{
			#a is smaller
			#return -1; 
			#return $a_prev * (10 ** $a_next) <=> $b; 
			return $a_prev * (2.72 ** $a_next) <=> $b; 
		}
		else
		{
			if ($a_next < $b_next)
			{
				#a is smaller
				return -1; 
			}
			elsif ($a_next > $b_next)
			{
				return 1; 
			}
			else
			{
				return $a_prev <=> $b_prev; 
			}
		}
	}
}

#sort templates by e-value
$total = @rank;
$total > 0 || die "No significant templates are found. Stop.\n";
for ($i = $total - 1; $i > 0; $i--)
{
	for ($j = 0; $j < $i; $j++)
	{
		$rec1 = $rank[$j];
		@fields = split(/\s+/, $rec1);
		$eva1 = $fields[2];
		$rec2 = $rank[$j+1];
		@fields = split(/\s+/, $rec2);
		$eva2 = $fields[2];
		if (&comp_evalue($eva1, $eva2)	== 1)
		{
			$rank[$j] = $rec2;
			$rank[$j+1] = $rec1;
		}
	}
} 
open(RANK, ">$name.rank");
$count = 1;
while (@rank)
{
	$line = shift @rank;
	@fields = split(/\s+/, $line);
	print RANK "$count\t$fields[1]\t$fields[2]\n";
	$count++;
}
close RANK;

#sort local alignments by evalue
$total = @rlocal;
for ($i = $total - 1; $i > 0; $i--)
{
	for ($j = 0; $j < $i; $j++)
	{
		$rec1 = $rlocal[$j]; 
		@fields = split(/\s+/, $rec1);
		$eva1 = $fields[3];
		$rec2 = $rlocal[$j+1]; 
		@fields = split(/\s+/, $rec2);
		$eva2 = $fields[3];
		if (&comp_evalue($eva1, $eva2)	== 1)
		{
			$rlocal[$j] = $rec2;
			$rlocal[$j+1] = $rec1;
		}
	}		
} 

open(RLOCAL, ">$fasta_file.local");
print RLOCAL "$name\n\n";
$total = @rlocal;
for ($i = 0; $i < $total; $i++)
{
	print RLOCAL $rlocal[$i];
	if ($i < $total - 1)
	{
		print RLOCAL "\n";	
	}
} 
close RLOCAL;

#die "stop here.\n";

####################################################End of Search two databases###########################

print "generate combined PIR alignments...\n";

system("$meta_dir/script/compass_align_comb.pl $script_dir $fasta_file $fasta_file.local $cm_min_cover_size $cm_max_gap_size $cm_max_linker_size $cm_evalue_comb $adv_comb_join_max_size $cm_evalue_diff $fasta_file.pir");  

open(PIR, "$fasta_file.pir") || die "can't generate pir file from local alignments.\n";
@pir = <PIR>;
close PIR; 
if (@pir <= 4)
{
	die "no pir alignments are generated from target: $name\n"; 
}

print "Use Modeller to generate tertiary structures...\n"; 
#generate tertiary structure from pir msa.
#system("$script_dir/pir2ts.pl $modeller_dir $atom_dir $work_dir $fasta_file.pir $model_num");

################com0 is redudant of com1############################
#so we don't need to generate it.
#system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $work_dir $fasta_file.pir $cm_model_num");
#`mv model.log $fasta_file.log`; 
####################################################################


if (-f "$name.pdb")
{
	`mv $name.pdb com0.pdb`; 
	`mv $name.pir com0.pir`; 
}

print "Generate a model from each template...\n";
system("$meta_dir/script/main_compass_easy.pl $option_file $fasta_file $work_dir");

print "Comparative modelling for $name is done.\n"; 

