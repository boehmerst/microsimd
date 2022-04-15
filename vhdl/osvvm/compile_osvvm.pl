#!/usr/bin/perl

use File::Basename;
use File::Path;
use File::Copy;
use FileHandle;
use Cwd;
use strict;

my @sorted_src = (
  './rtl/SortListPkg_int.vhd',
  './rtl/RandomBasePkg.vhd',
  './rtl/RandomPkg.vhd',
  './rtl/MessagePkg.vhd',
  './rtl/CoveragePkg.vhd'
);

my $toolchain = 'modelsim';
my $lib       = 'osvvm';

my $dir = $ENV{'DEST_PROJECTS'} . "/" . $lib . "/" . $toolchain;
my $mslib = $dir . "/lib";

# greate library
mkpath($dir);       
system("vlib $mslib 2>&1 | \$GIT_PROJECTS/flow/colorize.pm") if(!( -e $mslib));

# add library mapping to modelsim.ini
my $modelsim = $ENV{'MODELSIM'};
my $modelsim_file = new FileHandle;
open($modelsim_file, $modelsim) or die "could not read modelsim.ini";

my $lines = [<$modelsim_file>];
close($modelsim_file);
open($modelsim_file, ">$modelsim") or die "could not write modelsim.ini";
  
foreach my $line (@{$lines}) {
  print $modelsim_file $line;
  if($line =~ /\[LIBRARY\]/ig) {
    print $modelsim_file "$lib = \${DEST_PROJECTS}/$lib/modelsim/lib\n";
  }
}

close($modelsim_file);

# compile files in given order using vhdl-2008
foreach my $file (@sorted_src) {
  system("vcom -work osvvm -quiet -2008 $file");
}

