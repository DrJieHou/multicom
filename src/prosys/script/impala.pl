#!/usr/bin/perl -w
############################################################################
#use impala to blast a sequence to a chk profile of target
#Inputs: blast dir, query file(fasta), target file(fasta), target chk file,
#    and output file.
#Author: Jianlin Cheng
#Date: 5/05/2005
#bug fix: logarithm of 0, 9/06/05, Jianlin Cheng
############################################################################
if (@ARGV != 6)
{
	die "need six parameters:script_dir  blast dir, query file, target file, target chk file(naming: name.chk), output file.\n";
}
$script_dir = shift @ARGV;
$blast_dir = shift @ARGV;
$query_fasta = shift @ARGV;
$target_fasta = shift @ARGV;
$target_chk = shift @ARGV;
-d $script_dir || die "can't find script dir.\n"; 
-f $target_chk || die "can't find target chk file.\n";
#if ($target_chk =~ /(.+)\.chk/)
#{
#	$prof_name = $1; 
#}
#else
#{
#	die "the format of the target chk file is not correct. should be like name.chk\n";
#}
$out_file = shift @ARGV;
-d $blast_dir || die "can't find blast dir.\n";

-f $query_fasta || die "can't find query fasta file.\n";
open(QUERY, $query_fasta);
$code1 = <QUERY>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <QUERY>;
chomp $seq1; 
close QUERY;
$query_length = length($seq1); 

-f $target_fasta || die "can't find target fasta file.\n";
open(TARGET, $target_fasta);
$code2 = <TARGET>;
chomp $code2; 
$code2 = substr($code2, 1);
$seq2 = <TARGET>;
chomp $seq2; 
close QUERY;

##################################################################################
#create profile database accepted by rps blast
#primary process using makemat
#inputs: chk file, fasta file of target(suffix:cxx), database file containing the list of of profile file names
#the database file containing the list of fasta files
##################################################################################
#make a temporay fasta file
#we get to make it thread-safe, the tmp_fasta file name must be uniq across threads.
#so we need to generate uniq name from qeury fasta file name
#not path is used for database
$idx = rindex($query_fasta, "/");
if ($idx >= 0)
{
	$uniq = substr($query_fasta, $idx+1);
}
else
{
	$uniq = $query_fasta; 
}
$uniq =~ s/\./_/g; 
$uniq = "rps" . $uniq;

#copy the chk file to the current dir
`cp $target_chk $uniq.chk`; 
#copy target fasta file 
`cp $target_fasta $uniq.cxx`; 

#create a file containing a list of profile files
open(DBPN, ">$uniq.pn") || die "can't create db list for profiles.\n";
print DBPN "$uniq.chk\n"; 
close DBPN;

#create a file containing a list of fasta files
open(DBSN, ">$uniq.sn") || die "can't create db list for fasta file.\n";
print DBSN "$uniq.cxx\n";
close DBSN;

system("$blast_dir/makemat -P $uniq -S 1");

#secondary process
system("$blast_dir/copymat -P $uniq -r F");

#searching the database using rpsblast
system("$blast_dir/impala -i $query_fasta -P $uniq -o $out_file.impala -e 20");

#read and parse alignment results here : $out_file.blast
system("$script_dir/cm_parse_impala.pl $out_file.impala $out_file.local");
open(LOCAL, "$out_file.local") || die "can't read blast local alignments.\n";
@local = <LOCAL>;
if (@local < 3)
{
	print "feature num: 5\n";
	print "0 ", "10 ", "0 ", "0 ", "0 ", "\n\n"; 
	print  join("", @local); 

	open(OUT, ">$out_file") || die "can't create output file.\n";
	print OUT "feature num: 5\n";
	print OUT "0 ", "10 ", "0 ", "0 ", "0 ", "\n\n"; 
	print OUT join("", @local); 

	`rm $uniq*`; 
	`rm $out_file.impala $out_file.local`; 

	die "no local alignments are generated from impala, use default values.\n";
}
close LOCAL;
shift @local;
shift @local;
$max = $local[0]; 
chomp $max;
$tname = $tlen = $gap_rate = "";
($tname, $tlen, $score, $evalue, $align_len, $int_rate, $pos_rate, $gap_rate) = split(/\s+/, $max);
#take a log on evalue
if ($evalue =~ /^e-(\d+)/)
{
	$evalue = "-" . $1; 
}
elsif ($evalue =~ /([\d\.]+)e-(\d+)/)
{
	$evalue = log($1);
	$evalue -= $2; 
}
elsif ($evalue =~ /([\d\.]+)/)
{
	if ($1 > 0)
	{
		$evalue = log($1);
	}
	else
	{
		$evalue = -200; 
	}
}
else
{
	die "unknown format of evalue\n"; 
}

print "feature num: 5\n";
print $score/$query_length, " ", $evalue, " ", $align_len / $query_length, " ", $int_rate, " ", $pos_rate, " ", "\n\n"; 
print  join("", @local); 

#for each aligned segment: 
open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 5\n";
print OUT $score/$query_length, " ", $evalue, " ", $align_len / $query_length, " ", $int_rate, " ", $pos_rate, " ", "\n\n"; 
	
print OUT join("", @local); 
#clean-up (remove the tempoary files)
`rm $uniq*`; 
`rm $out_file.impala $out_file.local`; 
