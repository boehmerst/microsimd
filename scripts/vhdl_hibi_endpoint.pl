#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use FileHandle;
use File::Path;
use File::Copy;
use POSIX;
use List::Util qw(max min);

use strict;

my $timestamp = localtime();
my $user      = $ENV{'USER'};
my $host      = $ENV{'HOSTNAME'};

my $entity          = "hibi_dma";
my $unit            = "hibi_dma";
my $lib             = "work";
my $hibi_addr_width = 16;
my $mem_addr_width  = 32;
my $mem_data_width  = 32;
my $count_width     = 10;
my $channels        = 4;
my $hostif;
my $chaining;
my $custom_db;
my $gpio;

# command line options table
my %option = 
  ( 'entity'           => { 'string' => 'entity|e=s',             'ref' => \$entity,          'help' => 'Specify entity name'                   },
    'unit'             => { 'string' => 'unit|u=s',               'ref' => \$unit,            'help' => 'Specify unit name'                     }, 
    'lib'              => { 'string' => 'lib|l=s',                'ref' => \$lib,             'help' => 'Specify library name'                  },
    'hibi_addr_width'  => { 'string' => 'hibi_addr_width|haw=i',  'ref' => \$hibi_addr_width, 'help' => 'Specify hibi address width'            },
    'mem_addr_width'   => { 'string' => 'mem_addr_width|maw=i',   'ref' => \$mem_addr_width,  'help' => 'Specify memory address width'          },
    'mem_data_width'   => { 'string' => 'mem_data_width|mdw=i',   'ref' => \$mem_data_width,  'help' => 'Specify memory data width'             },    
    'count_width'      => { 'string' => 'count_width|cnt=i',      'ref' => \$count_width,     'help' => 'Specify transfer counter width'        },
    'channels'         => { 'string' => 'channels|ch=i',          'ref' => \$channels,        'help' => 'Specify number of channels'            },
    'hostif'           => { 'string' => 'hostif|hi=s',            'ref' => \$hostif,          'help' => 'DMA has external host interface'       },
    'chaining'         => { 'string' => 'chaining|chn',           'ref' => \$chaining,        'help' => 'Support for chaining DMA transfers'    },
    'custom_db'        => { 'string' => 'custom_db|cdb=s',        'ref' => \$custom_db,       'help' => 'Provide database with cutom registers' },
    'gpio'             => { 'string' => 'gpio|g',                 'ref' => \$gpio,            'help' => 'Support for GPIO'                      },
    'help'             => { 'string' => 'help|?',                 'ref' => \&help,            'help' => 'Show help'                             },
  ); 

# handle command line options
GetOptions( $option{'entity'}          {'string'} => $option{'entity'}          {'ref'},
            $option{'unit'}            {'string'} => $option{'unit'}            {'ref'},
            $option{'lib'}             {'string'} => $option{'lib'}             {'ref'},
            $option{'hibi_addr_width'} {'string'} => $option{'hibi_addr_width'} {'ref'},
            $option{'mem_addr_width'}  {'string'} => $option{'mem_addr_width'}  {'ref'},
            $option{'mem_data_width'}  {'string'} => $option{'mem_data_width'}  {'ref'},
            $option{'count_width'}     {'string'} => $option{'count_width'}     {'ref'},
            $option{'channels'}        {'string'} => $option{'channels'}        {'ref'},
            $option{'hostif'}          {'string'} => $option{'hostif'}          {'ref'},
            $option{'chaining'}        {'string'} => $option{'chaining'}        {'ref'},
            $option{'hostif'}          {'string'} => $option{'hostif'}          {'ref'},
            $option{'custom_db'}       {'string'} => $option{'custom_db'}       {'ref'},
	    $option{'gpio'}            {'string'} => $option{'gpio'}            {'ref'},	    
            $option{'help'}            {'string'} => $option{'help'}            {'ref'},
          ) or die;


mkpath("./$unit");
mkpath("./$unit" . "/db");
mkpath("./$unit" . "/rtl");

system("vhdl_hibi_endpoint_core_gen.pl --entity=$entity --lib=$lib --hibi_addr_width=$hibi_addr_width" .
" --mem_addr_width=$mem_addr_width --mem_data_width=$mem_data_width --count_width=$count_width;");

system("vhdl_hibi_endpoint_ctrl_gen.pl --entity=$entity --lib=$lib;");

my $args = "";

if(defined($chaining)) {
  $args = $args . " --chaining";
}

if(defined($gpio)) {
  $args = $args . " --gpio";
}


# TODO this option is required actually until top level generator is adapted
system("vhdl_hibi_endpoint_trigger_gen.pl --entity=$entity;");

system("vhdl_hibi_endpoint_db_gen.pl --entity=$entity --hibi_addr_width=$hibi_addr_width  --mem_addr_width=$mem_addr_width" .
  " --count_width=$count_width --channels=$channels $args;");

if(defined($hostif)) {
  die if not ($hostif eq "full" or $hostif eq "mem" or $hostif eq "regfile");
  $args = $args . " --hostif";
}

system("vhdl_hibi_endpoint_top_gen.pl --entity=$entity --lib=$lib --channels=$channels $args;");

system("vhdl_hibi_endpoint_pkg_gen.pl -entity=$entity --hibi_addr_width=$hibi_addr_width" .
" --mem_addr_width=$mem_addr_width --mem_data_width=$mem_data_width --count_width=$count_width --channels=$channels;");


# TODO: Make this overideable
my $register_count = 3;

if (defined($chaining)) {
  $register_count += 4*$channels;
} 
else {
  $register_count += 3*$channels;
}

if(defined($gpio)) {
  $register_count  += 3;
}

my $addr_width = ceil(log($register_count)/log(2));

# TODO: let regfile generator check for max width?
my $max_known_reg_width = 15 + 5 + 1 + 1; # bit 15 = direction + 5 bit hibi_cmd + 1 bit const_addr
my $reg_width           = max $mem_addr_width, $max_known_reg_width;

if(defined($hostif)) {
  if($hostif eq "full" or $hostif eq "mem") {
    $addr_width = max $mem_addr_width, $addr_width;
    $reg_width  = max $mem_data_width, $reg_width;
  }
}

if(defined($custom_db)) {
  system("vhdl_regfile_gen.pl --database=./$entity" . ".pl" . " --database=$custom_db" . " --addr_width=$addr_width --data_width=$reg_width --lib=$lib;");
  system("vhdl_pkg_gen.pl  --database=./$entity" . ".pl" . " --database=$custom_db" . " --addr_width=$addr_width;");
  system("vhdl_types_gen.pl --database=./$entity" . ".pl" . " --database=$custom_db" . " --addr_width=$addr_width --data_width=$reg_width;");
}
else {
  system("vhdl_regfile_gen.pl --database=./$entity" . ".pl" .  " --addr_width=$addr_width --data_width=$reg_width --lib=$lib;");
  system("vhdl_pkg_gen.pl  --database=./$entity" . ".pl" . " --addr_width=$addr_width;");
  system("vhdl_types_gen.pl --database=./$entity" . ".pl" . " --addr_width=$addr_width --data_width=$reg_width;");
}


move("./$entity" . "_core.vhd",            "./$unit" . "/rtl");
move("./$entity" . "_pkg.vhd",             "./$unit" . "/rtl");
move("./$entity" . "_regfile_pkg.vhd",     "./$unit" . "/rtl");
move("./$entity" . "_regif_types_pkg.vhd", "./$unit" . "/rtl");
move("./$entity" . "_regfile.vhd",         "./$unit" . "/rtl");
move("./$entity" . "_ctrl.vhd",            "./$unit" . "/rtl");
move("./$entity" . "_gif_mux.vhd",         "./$unit" . "/rtl") if defined($hostif);
move("./$entity" . "_trigger.vhd",         "./$unit" . "/rtl") if defined($chaining);
move("./$entity" . ".vhd",                 "./$unit" . "/rtl");
move("./$entity" . ".pl",                  "./$unit" . "/db");
        
# help
sub help
{
  my $max_length = 0;

  print "usage: $0 [OPTION]\n\n";

  # find maximum string length
  foreach my $cmd (keys(%option))
  {
    my @alias  = split(/[\|,=]/, $option{$cmd}{'string'});
    my $string = "--" . $alias[0] . ", -" . $alias[1] . ",";
    $max_length = length($string) if length($string) > $max_length;
  }

  # print out aligned
  foreach my $cmd (sort(keys(%option)))
  {
    my @alias  = split(/[\|,=,+]/, $option{$cmd}{'string'});
    my $string = "--" . $alias[0] . ", -" . $alias[1] . ",";
    my $length = length($string);
    my $space  = ' 'x($max_length - $length);

    print "$string $space $option{$cmd}{'help'}\n";
  }

  exit 1;
}

