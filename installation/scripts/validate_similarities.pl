#!/usr/bin/perl -w
#perl /home/jh7x3/multicom/installation/scripts/validate_similarities.pl  T1006  /home/jh7x3/multicom/test_out/T1006_out/full_length/meta /home/jh7x3/multicom//installation/benchmark
if (@ARGV != 4) {
  print "Usage: structure1  structure2\n";
  exit;
}
$targetid = $ARGV[0];
$test_dir = $ARGV[1]; 
$benchmark_dir = $ARGV[2];
$prefix = $ARGV[3];

$GLOBAL_PATH="/storage/hpc/scratch/jh7x3/multicom/";


print "\n---------------------------------------------------------------------------------------------------\n";
print "Evaluating structure similarities between predicted and benchmark predictions for $targetid:\n";
opendir(FILES,"$test_dir/") || die "Failed to open directory $test_dir/\n";
@files = readdir(FILES);
closedir(FILES);
$avg_gdt_predict = 0;
$avg_gdt2_benchmark = 0;
$avg_rmsd_predict = 0;
$avg_rmsd2_benchmark = 0;
$model_num = 0;

printf "\n%-20s\t", 'Model';
printf "%-20s\t", 'GDT-TS';
printf "%-20s\n", 'RMSD';

foreach $file (sort @files)
{
	if($file eq '.' or $file eq '..' or substr($file,length($file)-4) ne '.pdb' or index($file,$prefix) < 0)
	{
		next;
	}	
	
	$predict_file = "$test_dir/$file";
	$benchmark_file = "$benchmark_dir/$file";
	
	if(!(-e $benchmark_file))
	{
		next;
	}
	
	### evaluate two pdb
	$model_num ++;
	
	($gdttsscore1,$rmsd1) = cal_sim($predict_file,$benchmark_file);
	$avg_gdt_predict += $gdttsscore1;
	$avg_rmsd_predict += $rmsd1;
	
	
	printf "%-20s\t", $file;
	printf "%-20f\t", $gdttsscore1;
	printf "%-20f\n", $rmsd1;
	
	
	
}

$avg_gdt_predict = sprintf("%.5f",$avg_gdt_predict/$model_num);
$avg_rmsd_predict = sprintf("%.5f",$avg_rmsd_predict/$model_num);


printf "\n%-20s\t", 'Model';
printf "%-20s\t", 'GDT-TS';
printf "%-20s\n", 'RMSD';

printf "%-20s\t", 'Average';
printf "%-20f\t", $avg_gdt_predict;
printf "%-20f\n", $avg_rmsd_predict;


print "done\n";
print "---------------------------------------------------------------------------------------------------\n\n";
sleep(1);



sub cal_sim
{
	my ($file,$native) = (@_);
	$command1="$GLOBAL_PATH/tools/tm_score/TMscore_32 $file $native";
	my @result1=`$command1`;
	my $tmscore=0;
	my $maxscore=0;
	my $gdttsscore=0;
	my $rmsd=0;
	foreach $ln2 (@result1){
		chomp($ln2);
		if ("RMSD of  the common residues" eq substr($ln2,0,28)){
			$s1=substr($ln2,index($ln2,"=")+1);
			while (substr($s1,0,1) eq " ") {
				$s1=substr($s1,1);
			}
			$rmsd=1*$s1;
		}
		if ("TM-score" eq substr($ln2,0,8)){
			$s1=substr($ln2,index($ln2,"=")+2);
			$s1=substr($s1,0,index($s1," "));
			$tmscore=1*$s1;
		}
		if ("MaxSub-score" eq substr($ln2,0,12)){
			$s1=substr($ln2,index($ln2,"=")+2);
			$s1=substr($s1,0,index($s1," "));
			$maxscore=1*$s1;
		}
		if ("GDT-score" eq substr($ln2,0,9)){
			$s1=substr($ln2,index($ln2,"=")+2);
			$s1=substr($s1,0,index($s1," "));
			$gdttsscore=1*$s1;
		}
	}
	return ($gdttsscore,$rmsd);

	
}
