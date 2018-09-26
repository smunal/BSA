#
# copyright 2008 BladeLogic, Inc. All rights reserved.

eval { require 5.008};
if ($@) {
  print "the Script requires perl version >= 5.8.0, please check the current version of perl on the system\n";
  exit(1);
}

use Sys::Hostname;
use Getopt::Std;
use FindBin qw($Bin);

$|=1;

my %arguments = %{processOptions(@ARGV)};     # Processing options

my $workingDirectory  =  $arguments{'workingDirectory'};
my $depotfolder=  $arguments{'Depotfolder'};  
my $os_name= $arguments{'os'};

# Fire a jython ApplyReturnCodes.jli that will apply all mapped return codes to the depot items
my $host=hostname;
chdir($workingDirectory) or die "\n Cannot change directory to $workingDirectory";  

$cmd = "\"$workingDirectory/Jython/bljython\" \"$workingDirectory/Jython/applyReturnCodes.jli\" ". 
       "\"$depotfolder\" ". 
       "\"$os_name\" ".
       "\"$host\"";
       
       
print $cmd;
my $returnStatus = do_system($cmd);

if ($returnStatus) {
    print STDERR "\nApplyReturnCodes Failed [$returnStatus] \n";
    exit($returnStatus);
} else {
    print "\nApplying return Codes  Completed. \n";
    exit(0);
}


sub do_system {
    
    my $output = `$cmd`;
    #$cmdstatus = system($cmd);
    my $cmdstatus = $?;
    $cmdstatus = $cmdstatus >> 8;
    my @output = split '\n', $output;
    if (scalar @output > 0) {
        foreach my $line (@output) {
            chomp($line);
            print "$line \n";
        }
    }
    return $cmdstatus;
}

sub processOptions {
  
  my $num_args = $#ARGV;
  my %arguments;

# Get command-line options
  our($opt_f,$opt_h, $opt_d, $opt_s,$opt_w);
  getopts('hd:f:s:w:');
  print "-d $opt_d\n-s $opt_s\n-w $opt_w\n";
   
  if (($num_args == -1) ||  (!$opt_d) || (!$opt_s) || (!$opt_w)) {
    print STDERR "-d, -s and -w are compulsory parameter \n";
    usage();
    exit(0);
  }
  
  if($opt_h){
     print "\n";
     usage();
     exit(1);
  }   
  
  $arguments{'Depotfolder'} = $opt_d;
  $arguments{'os'} = $opt_s;
  $arguments{'workingDirectory'} = $opt_w;

  return (\%arguments);
}

sub usage{

    print STDERR << "HELP";

    NAME

    ApplyRetrunCodes.pl - Applies return Codes to Software Depot Items

    SYNOPSIS
     
    ApplyReturnCodes.pl -d <depotfoldername> -s <os_name> -w <working-directory>
    
    -h   Prints out this help usage section 
    
    -d   Name of the depot folder where software items are present
    
    -s   Name of the Operating System.
    
    DESCRIPTION
     The script calls the jython script applyReturnCodes.jli to Set mapped return codes
     which are read from  the jython.conf file as per the -s (os name) parameter 
     for all the S/W Items present in the depot folder specified by -d.
     

HELP

}