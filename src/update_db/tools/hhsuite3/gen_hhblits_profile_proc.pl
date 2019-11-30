#!/usr/bin/perl -w
#######################################################################
#generate template files using multiple threads
#1/9/2014
#Jianlin Cheng
#update: Jie Hou, 2019/08/15
#######################################################################
if (@ARGV != 3)
{
	die "need three parameters: option file(option_prep), fasta file(fasta), output dir\n"; 
}
$option_file = shift @ARGV; 
$fasta_file = shift @ARGV; #$database_path/fr_lib/sort90
$out_dir = shift @ARGV; #$database_path/hhsuite3_dbs/profiles


use Cwd 'abs_path';
$option_file = abs_path($option_file);
$fasta_file = abs_path($fasta_file);
$out_dir = abs_path($out_dir);

-d $out_dir || die "can't read $out_dir.\n";

$work_dir = $out_dir;

#read option file
$thread_num = "";
$running_mode = "";
$set_seq_dir = "";
open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^prosys_dir/)
	{
		$other = "";
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}
	if ($_ =~ /^thread_num\s*=\s*(\S+)/)
	{
		$thread_num = $1; 
	}
	if ($_ =~ /^running_mode\s*=\s*(\S+)/)
	{
		$running_mode = $1; 
	}
	if ($_ =~ /^set_seq_dir\s*=\s*(\S+)/)
	{
		$set_seq_dir = $1; 
	}

}
-d $prosys_dir || die "can't find $prosys_dir.\n";

if($running_mode eq 'thread')
{
  print "Running feature generating using $thread_num thread\n\n";
}elsif($running_mode eq 'sbatch')
{
  print "Running feature generating using $thread_num sbatch\n\n";
}else{
  $running_mode = 'thread';
  print "Setting the feature generating mode to thread. Using $thread_num thread\n\n";
}
#############################
chdir $work_dir;
$full_path = `pwd`;
chomp $full_path;
#############################

#### check if profiles have been generated

open(INPUT, $fasta_file) || die "can't open $fasta_file.\n";
@fasta = <INPUT>;
close INPUT;

open(OUTPUT, ">$fasta_file.hhsuitenew") || die "can't open $fasta_file.new.\n";
$seq_num=0;
while (@fasta)
{
	$name = shift @fasta;
	$seq = shift @fasta;

	chomp $name;
	chomp $seq;
	$name = substr($name, 1);
 
	#check if the output file exist. if so, nothing needs to be done.		
	if (-f "$out_dir/$name.a3m" && -f "$out_dir/$name.hhm" && -f "$out_dir/$name.cs219")
	{
		warn "The hhblits profile files for $name exist. Skip.\n";
		next;
	}else{
    print OUTPUT ">$name\n$seq\n";
    $seq_num++;
  }
}
print "Total $seq_num new proteins are found\n\n";
#################################


open(LIB, "$fasta_file.hhsuitenew") || die "can't read fasta file $fasta_file.new.\n";
@fasta = <LIB>;
close LIB;

`chmod 777 $fasta_file.hhsuitenew`;
#split template library for threads
$total = @fasta / 2; 
#if ($total < 2 * $thread_num)
#{
#	$thread_num = 1; 
#}
if($total == 0)
{
	$thread_num = 1;
}elsif($total <= $thread_num)
{
	$thread_num = $total;
}

print "Using $thread_num cpus\n\n";

if($total > $thread_num)
{
	$max_num = int($total / $thread_num) + 1; 
}else{
	$max_num = int($total / $thread_num);
}

$thread_dir = "pthread";
for ($i = 0; $i < $thread_num; $i++)
{
	`mkdir $thread_dir$i`; 	

	open(THREAD, ">$thread_dir$i/lib$i.fasta") || die "can't create template file for thread $i\n";
	#allocate sequences for thread
	for ($j = $i * $max_num; $j < ($i+1) * $max_num && $j < $total; $j++)
	{
		print THREAD $fasta[2*$j];
		print THREAD $fasta[2*$j+1]; 
	}
	close THREAD;
}


#sub gen_temps 
#{

#	my ($gen_program, $t_option_file, $t_fasta_file, $t_out_dir) = @_;
#	`$gen_program $t_option_file $t_fasta_file $t_out_dir`; 	
#}

if($running_mode eq 'thread')
{
  $post_process = 0; 
  
  for ($i = 0; $i  < $thread_num; $i++)
  {
  	if ( !defined( $kidpid = fork() ) )
  	{
  		die "can't create process $i\n";
  	}
  	elsif ($kidpid == 0)
  	{
  		#within the child process
  		print "start thread $i to generate hhsuite profile\n";
  		system("perl /home/jhou4/tools/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile.pl /home/jhou4/tools/multicom/tools/hhsuite-3.2.0/ 8 $set_seq_dir /home/jhou4/tools/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08  $work_dir/$thread_dir$i/lib$i.fasta  $work_dir/$thread_dir$i");
     
  		goto END;
  	}
  	else
  	{
  		$thread_ids[$i] = $kidpid;
  	}
  	
  }
  #collect results
  #wait threads to return
  use Fcntl qw (:flock);
  if ($i == $thread_num && $post_process == 0)
  {
  	#print "postprocess: $i\n";
  	$post_process = 1; 
  	chdir $full_path;
  
  	for ($i = 0; $i < $thread_num; $i++)
  	{
  		#$threads[$i]->join;
  		if (defined $thread_ids[$i])
  		{
  			print "wait thread $i ";
  			waitpid($thread_ids[$i], 0);
  			$thread_ids[$i] = ""; 
  			print "done\n";
  #if there too many files, a direct moving of files will fail. 
  			open(LIBFILE, "$work_dir/$thread_dir$i/lib$i.fasta") || die "can't read lib$i.fasta.\n";
  			@file_list = <LIBFILE>;
  			close LIBFILE;
  			while (@file_list)
  			{
  			        $name = shift @file_list;
  			        chomp $name;
  			        $name = substr($name,1);
  			      	`mv $work_dir/$thread_dir$i/$name.* $work_dir`; 
  			        shift @file_list;
  			}
  
  			#`rm $work_dir/$thread_dir$i/lib$i.fasta`; 
  
  			`rm -rf $work_dir/$thread_dir$i`; 
  		}
  
  		#remove thread dir
  	}
  }
}elsif($running_mode eq 'sbatch')
{

    for ($i = 0; $i < $thread_num; $i++)
    {
    	if (-f "$work_dir/$thread_dir$i.done"){
    		print "\nLooks like thread $i has already finished.. Not running anything..";
    		next;
    	}
    	print "\n";
    	print "Forking MULTICOM jobs for thread $i\n";
    	print "Log file at -> $work_dir/$thread_dir$i.log\n";
    	system("touch $work_dir/$thread_dir$i.queued");
    	chdir("$work_dir");
    	open SB, ">$work_dir/$thread_dir$i.sh" or confess $!;
    	print SB "#!/bin/bash -l\n";
    	print SB "#SBATCH -J db-$i\n";
    	print SB "#SBATCH -o db-$i.log\n";
    	print SB "#SBATCH -p hpc4,hpc5,Lewis\n";
    	print SB "#SBATCH -n 1\n";
    	print SB "#SBATCH --mem 10G\n";
    	print SB "#SBATCH -t 1-00:00\n";
    	print SB "mv $work_dir/$thread_dir$i.queued $work_dir/$thread_dir$i.running\n";
  		#within the child process
  		print SB "echo 'start thread $i to generate hhsuite3 profile'\n";
  		print SB "echo 'perl /home/jhou4/tools/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile.pl /home/jhou4/tools/multicom/tools/hhsuite-3.2.0/ 1 $set_seq_dir /home/jhou4/tools/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08  $work_dir/$thread_dir$i/lib$i.fasta  $work_dir/$thread_dir$i'\n";
  		print SB "perl /home/jhou4/tools/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile.pl /home/jhou4/tools/multicom/tools/hhsuite-3.2.0/ 1 $set_seq_dir /home/jhou4/tools/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08  $work_dir/$thread_dir$i/lib$i.fasta  $work_dir/$thread_dir$i &> $work_dir/$thread_dir$i.log\n";
    	print SB "mv $work_dir/$thread_dir$i.running $work_dir/$thread_dir$i.done\n";
    	close SB;
    	system("chmod +x $work_dir/$thread_dir$i.sh");
    	# Option 1 for parallelization (slurm managed HPC cluster)
    	system("sbatch $work_dir/$thread_dir$i.sh");
    	# Option 2 for parallelization (multiple CPUs in one computer)
    	# Remove the "&" for running serially
    	#system "./$thread_dir$i.sh > $thread_dir$i.log &";
    	sleep 1;
    }
    
    print "\n";
    print("Wait for all MULTICOM jobs to finish (check individual log files for progress)..\n");
    
    $running = 1;
    while(int($running) > 0){
    	sleep 10;
    	$running = 0;
    	for ($i = 0; $i < $thread_num; $i++)
      {
    		if (-f "$work_dir/$thread_dir$i.queued"){
    			$running = 1;
    			last;
    		}
    		if (-f "$work_dir/$thread_dir$i.running"){
    			$running = 1;
    			last;
    		}
    	}
    }
    
    print "\n";
    print "Looks like all jobs have completed, checking to see if expected model files are present..\n";
    
    for ($i = 0; $i < $thread_num; $i++)
    {
			open(LIBFILE, "$work_dir/$thread_dir$i/lib$i.fasta") || die "can't read lib$i.fasta.\n";
			@file_list = <LIBFILE>;
			close LIBFILE;
			while (@file_list)
			{
			        $name = shift @file_list;
			        chomp $name;
			        $name = substr($name,1);
			      	`mv $work_dir/$thread_dir$i/$name.* $work_dir`; 
			        shift @file_list;
			}

			#`rm $work_dir/$thread_dir$i/lib$i.fasta`; 

			#`rm -r $work_dir/$thread_dir$i`; 
   }
  
}else{
  die "Incorrect running mode ($running_mode), please check the option file $option_file\n\n";
}
## clean folders
for ($i = 0; $i < $thread_num; $i++)
{
  if(-d "$work_dir/$thread_dir$i" or -e "$work_dir/$thread_dir$i.done")
  {
    `rm -rf $work_dir/$thread_dir$i*`;
  }
}

`rm $fasta_file.hhsuitenew`;

END:


