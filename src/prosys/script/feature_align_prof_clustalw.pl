#!/usr/bin/perl -w
##########################################################################
#Use clustwal to generate prof-profile alignment features
#input: script dir, clustalw dir, query file(fasta), query(msa),
# target file(fasta), target msa(generated by blast), output file
#output: alignment score normalized by query length and target length
#Also return the alignments, which will be used in 3d-generation or other
#score calculation. 
#, and the alignments 
#Author: Jianlin Cheng
#Date: 5/3/2005
##########################################################################
if (@ARGV != 7)
{
	die "need seven parameters: script dir, clustwal dir, query file(fasta), query msa(from blast), target file(fasta), target msa(from blast), output file.\n";
}
$script_dir = shift @ARGV;
$clustalw_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";
-d $clustalw_dir || die "can't find clustalw dir.\n";

$query_fasta = shift @ARGV;
-f $query_fasta || die "can't find query fasta file.\n";
open(QUERY, $query_fasta);
$code1 = <QUERY>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <QUERY>;
chomp $seq1; 
close QUERY;

$query_msa = shift @ARGV;
-f $query_msa || die "can't find query msa file.\n";

$target_fasta = shift @ARGV;
-f $target_fasta || die "can't find target fasta file.\n";

open(TARGET, $target_fasta);
$code2 = <TARGET>;
chomp $code2; 
$code2 = substr($code2, 1);
$seq2 = <TARGET>;
chomp $seq2; 
close QUERY;
$target_msa = shift @ARGV;
-f $target_msa || die "can't find target msa file.\n";

$out_file = shift @ARGV;

#both files must be in the current dir. 
$qmsa = $query_msa;
$idx = rindex($qmsa, "/");
if ($idx >= 0)
{
	$qmsa = substr($qmsa, $idx+1);
}
$tmsa = $target_msa;
$idx = rindex($tmsa, "/");
if ($idx >= 0)
{
	$tmsa = substr($tmsa, $idx+1);
}

#use output file to generate name: 8/21/05
$prefix = $out_file;
$idx = rindex($prefix,"/");
if ($idx >= 0)
{
	$prefix = substr($prefix, $idx+1);
}
$qmsa = $prefix . "_query";
$tmsa = $prefix . "_temp";
#convert fasta and msa to gde format multiple alignments
#system("$script_dir/msa2gde.pl $query_fasta $query_msa gde $query_msa.gde");
#system("$script_dir/msa2gde.pl $target_fasta $target_msa gde $target_msa.gde");
system("$script_dir/msa2gde.pl $query_fasta $query_msa gde $qmsa.gde");
system("$script_dir/msa2gde.pl $target_fasta $target_msa gde $tmsa.gde");

#alignment two msa using clustalw

#system("$script_dir/ali_prof_clustalw.pl $clustalw_dir/clustalw $query_msa.gde $target_msa.gde $query_msa.clu");
system("$script_dir/ali_prof_clustalw.pl $clustalw_dir/clustalw $qmsa.gde $tmsa.gde $qmsa.clu");

open(RES, "$qmsa.clu") || die "can't read clustalw results.\n";
$scores = <RES>;
$name1 = <RES>;
chomp $name1; 
$align1 = <RES>;
chomp $align1; 
$name2 = <RES>;
chomp $name2; 
$align2 = <RES>;
chomp $align2; 
close RES;

#consistency checking
if ($name1 ne $code1 || $name2 ne $code2)
{
	print "$name1 $code1 $name2 $code2\n";
	die "clustalw results doesn't match with query or target.\n";
}

#do a sequence checking
$aa1 = $align1;
$aa2 = $align2;
$aa1 =~ s/-//g;
$aa2 =~ s/-//g;
if ($aa1 ne $seq1 || $aa2 ne $seq2)
{
	print "$aa1\n$seq1\n$aa2\n$seq2\n";
	die "input sequences doesn't match results from clustalw.\n";
}

($score1, $score2) = split(/\s+/, $scores);
$score2 = 0;
open(OUT, ">$out_file") || die "can't create output file.\n";
print "feature num: 1\n";
print "$score1\n";
print "$name1\n$align1\n$name2\n$align2\n";
print OUT "feature num: 1\n";
print OUT "$score1\n";
print OUT "$name1\n$align1\n$name2\n$align2\n";
close OUT; 

#remove files
#`rm $query_msa.gde $target_msa.gde $query_msa.clu`; 
`rm $qmsa.gde $tmsa.gde $qmsa.clu`; 



