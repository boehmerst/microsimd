#!/usr/bin/perl

use File::Basename;
use FileHandle;
use Cwd;

use strict;

my $source  = $ARGV[0];
my $vdd_net = $ARGV[1];
my $gnd_net = $ARGV[2];

my @modules = (
  "msmp", 
  "cpu", 
  "hibi_mem_3", 
  "hibi_mem_wrapper_3", 
  "sp_sync_mem_9_32_71f8e7976e4cbc4561c9d62fb283e7f788202acb",
  "sky130_sram_2kbyte_1rw1r_32x512_8");

my $regexp  = sprintf('(%s)', join('|', @modules));


my $fh = new FileHandle;
open($fh, $source) or die "could not open $source";
my $lines = [<$fh>];
close($fh);

my $state = "idle";




# add power port definition to modules
foreach my $line (@{$lines})
{
  chomp($line);

  if($state eq "idle")
  {
     if($line =~ /^(module)(\s)($regexp)/)
     {
       $state = "insert";
       print "$line\n";
     }
     else
     {
       if($line =~ /(\s+)($regexp)(\s)(\w+)(\s)(\()/)
       {
         print "$line\n";
         print "$1$1\`ifdef USE_POWER_PINS\n";
         print "$1$1$1\.$vdd_net\($vdd_net\)\,\n";
         print "$1$1$1\.$gnd_net\($gnd_net\)\,\n";
         print "$1$1`endif\n";
       }
       else
       {
   	 print "$line\n";
       }
     }
   } 
   elsif($state eq "insert")
   {
      if($line =~ /^(\s+)(\()(input|output)(\s+)(\w+)(\,)/)
      { 
	$state = "idle";

        print "$1$2\n";
	print "$1\`ifdef USE_POWER_PINS\n";
	print "$1  inout $vdd_net\,\n";
	print "$1  inout $gnd_net\,\n";
	print "$1`endif\n";
	print "$1 $3$4$5$6\n";
      }
      else
      {
	print "$line\n";
      }
   }

}

