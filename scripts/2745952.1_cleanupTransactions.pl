#
# copyright 2006 BladeLogic, Inc. All rights reserved.
#
eval { require 5.008};
if ($@) {
  print "Kit requires perl version >= 5.8.0, please check the current version of perl on the system\n";
  exit(1);
}

use strict;
use Sys::Hostname;
use Getopt::Std;
use FindBin qw($Bin);

$|=1;

my %arguments = %{processOptions(@ARGV)};     # Processing options

my $batchJobName  =  $arguments{'BatchJobName'};
my $baseDir = $Bin;
my $workingDirectory = $arguments{'workingDirectory'};
my $jobGroup = $arguments{'JobGroup'};
my $depotGroup = $arguments{'DepotGroup'};
my $cleanupMode = $arguments{'CleanupMode'};
my $sharedFlag = $arguments{'AixSharedPayloadFlag'};
my $appServer = hostname;
my $cmd;
#my $userInfoFile =  $baseDir .'/'. 'Jython'. '/'. 'user_info.dat';

# Fire a jython loadAndDeployPatches.jli that will add all patches to depo and
# create a deploy job.

$cmd = "\"$workingDirectory/Jython/bljython\" \"$workingDirectory/Jython/cleanupTransactions.jli\" ". 
       "\"$batchJobName\" ". 
       "\"$jobGroup\" " .
       "\"$depotGroup\" " .
       "\"$cleanupMode\" ".
       "\"$sharedFlag\" ". # used for AIX kits
       "\"$appServer\" ";
       
       
       
print $cmd;
my $returnStatus = do_system($cmd);

if ($returnStatus) {
    print STDERR "Cleanup Failed [$returnStatus] \n";
    exit(1);
} else {
    print "Cleanup Completed. \n";
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
    our($opt_h, $opt_v, $opt_b, $opt_g, $opt_f, $opt_w, $opt_d, $opt_m, $opt_s);
    getopts('hvb:g:f:w:d:m:s:');
    print "-f $opt_f\n-b $opt_b\n-g $opt_g\n-w $opt_w\n-d $opt_d\n-m $opt_m\n-s $opt_s\n";
     
    if (($num_args == -1) ||  (!$opt_b) || (!$opt_g) || (!$opt_w) || (!$opt_d) || (!$opt_m) || (not defined $opt_s)) {
        print STDERR "-b, -w , -g, -d, -m and -s are compulsory parameter \n";
    #usage()
        exit(1);
    }
  
    if ($opt_m ne 'A' and $opt_m ne 'T') {
        print STDERR "-m takes either 'T' (Clean Transaction logs) or 'A' (Clean All) ".
                     "as valid values \n";
        exit(1);
    }
  
    $arguments{'BatchJobName'} = $opt_b;
    $arguments{'JobGroup'} = $opt_g;
    $arguments{'workingDirectory'} = $opt_w;
    $arguments{'DepotGroup'} = $opt_d;
    $arguments{'CleanupMode'} = $opt_m;
    $arguments{'AixSharedPayloadFlag'} = $opt_s; # Ignored for other kits
  

    return (\%arguments);
}