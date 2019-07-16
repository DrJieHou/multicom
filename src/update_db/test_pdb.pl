use Net::FTP;
use File::Copy qw(copy);
use Scalar::Util qw(looks_like_number);
#get the latest list of pdb
print "connect rcsb pdb database....\n";
#system("$ftp -l  -u anonymous -p anonymous \'ftp.rcsb.org;./pub/pdb/data/structures/all/pdb\' > $prosys_db_stat_dir/pdblist.txt"); 
#system("$ftp -l  -u anonymous -p anonymous \'ftp.wwpdb.org;./pub/pdb/data/structures/all/pdb\' > $prosys_db_stat_dir/pdblist.txt");  # this may take too long to timeout, not safe

$host = "ftp.wwpdb.org";
$username = "bye";
$password = "hello";
$ftpdir = "/pub/pdb/data/status/";
$ftpstructure = "/pub/pdb/data/structures/all/pdb/";
$file = "added.pdb";
$glob = '*';
@remote_folders;
#$from_date = 20070101;
$from_date = 19900101;
$end_date = 20070425;
$file_out = "pdblist.txt";
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$prosys_db_stat_dir = './';
$file_out = "$prosys_db_stat_dir/pdblist.txt";

if(-e $file_out)
{
	`> $file_out`;
}

$currentdate = sprintf("%4d%02d%02d",($year + 1900),($mon+1),$mday);
print "Current date is $currentdate\n";

#-- connect to ftp server
$ftp = Net::FTP->new($host) or die "Error connecting to $host: $!";

#-- login
$ftp->login($username,$password) or die "Login failed: $!";
 
#-- chdir to $ftpdir
$ftp->cwd($ftpdir) or die "Can't go to $ftpdir: $!";	

@remote_folders = $ftp->dir($glob);

$grabfolder = "";
# Look through each date folder on wwpdb and update according the folder date
foreach $folder (@remote_folders) 
{
	chomp $folder;
	if($folder eq '.' or $folder eq '..')
	{
		next;
	}
	if ($folder eq "") {
		next;
	}

	if (($folder <= $from_date) || ($folder > $end_date)){
			next;
	}else 
	{
    print "Saw $folder\n";
		$grabfolder = $folder;
		my $test = chop($folder);
		#print "Saw: $ftpdir" . "$folder\n";
		
		$ftp->cwd($ftpdir . $folder) or die "Can't go to $folder: $!";

		# DL the add.pdb file and adding a date to it
		$ftp->get($file, "add.pdb") or die "Can't get $file: $!";
		open(addpdf, "<add.pdb") or die "2Failed to open add.pdb, $!\n";
		open(pdbcode, ">>$file_out");
		
		while (<addpdf>) { 
			$code = $_;
			chomp $code; #pdb4md0.ent.gz
			print pdbcode "pdb$code.ent.gz\n"; 
		}
		close(addpdf);
		
		# Create pdb code file with dates
		close(pdbcode);
		
		$update = 1;
	}
}

if ($update  == 0){
	print "There are no new updates!\n";
	exit;
}
print "Checking pdb list $file_out\n\n";
#-- close ftp connection
$ftp->quit or die "Error closing ftp connection: $!";	
###############################  end to get pdblist


=pod

@pdb_list = (); 
$num=0;
open(LIST, "$prosys_db_stat_dir/pdblist.txt") || die "can't read the current pdb list.\n";
while (<LIST>)
{
	$line =  $_;
	chomp $line;
	push @pdb_list, $line;
	$num++;
	#if($num % 10000 ==0)
	#{
	#	print "$num proteins are loaded\n";
	#}
	#@files = split(/\s+/, $line); 
	#foreach $file(@files)
	#{
	#	if ($file =~ /\@$/)
	#	{
	#		$file = substr($file, 0, length($file)-1); 
	#		push @pdb_list, $file; 
	#	}
	#}
}
close LIST; 
print "Total ".@pdb_list." pdbs are collected!\n";
#find file that need to be downloaded
print "check new pdb files to download...\n"; 
foreach $file (@pdb_list)
{
	$code1 = substr($file, 0, index($file,".")); 
	if ( $current_files =~ /$code1/)
	{
		#find the pdb file, do nothing.
	}
	else
	{
		push @update_list, $file; 
	}
}


#download the list of all new pdb files
$num = @update_list;
print "There are $num new proteins to download.\n"; 
print "download new pdb files...\n"; 


$ftp = "$prosys_dir/script/autoftp";
-f $ftp || die "can't find ftp script.\n";

@update_list_released=(); ## under /pub/pdb/data/status/, the pdb name is added, but it may not released by the time
foreach $file (@update_list)
{
	#system("$ftp -u anonymous -p anonymous \'ftp.rcsb.org;./pub/pdb/data/structures/all/pdb;b;$file\'"); 
	system("$ftp -u anonymous -p anonymous \'ftp.wwpdb.org;./pub/pdb/data/structures/all/pdb;b;$file\' &>> $prosys_db_stat_dir/autoftp.log"); 
	if(-e $file) # some pdbs may not released yet
	{
		`mv $file $pdb_download_dir`; 
		print "$file are recently released!\n";
		push @update_list_released, $file; 
	}
}
$num = @update_list_released;
print "There are $num new proteins released.\n"; 

#add the new added files into pdb index
open(PDB_INDEX, ">>$pdb_index_file") || die "can't append pdb index file.\n";

$pdb_log = "$prosys_db_stat_dir/pdb_update_log";

if (! -f $pdb_log)
{
	`> $pdb_log`; 
}
open(PDB_NEW, ">$pdb_index_new") || die "can't create pdb index new file.\n";

open(PDB_LOG, ">>$pdb_index_new") || die "can't append pdb update log file.\n";
$day = `date`; 
print PDB_LOG "\n\n\n$day\nadd new pdb files:$num\n";

foreach $file (@update_list_released)
{
	print PDB_NEW $file, "\n"; 
	print PDB_LOG $file, "\n"; 
	print PDB_INDEX $file, "\n"; 
}
close PDB_LOG; 
close PDB_INDEX; 
close PDB_NEW;
print "PDB updating is done.\n"; 
=cut



