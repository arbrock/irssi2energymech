#!/usr/bin/perl
# (C) Andrew Brock 2017
# GPLv3 or later
#
# Reformat lines of the format:
# --- Log opened Sun Nov 08 00:33:38 2009
# 00:33  Rerogo (n=rerogo@66.83.137.5.nw.nuvox.net) has joined #shadows-of-fl
# 00:33  Irssi: #shadows-of-fl: Total of 2 nicks (1 ops, 0 halfops, 0 voices, 1 normal)
# to look more like:
# --- Log opened Thu Jan 05 19:14:08 2017
#
# 2017-01-05 19:14 -0600-!- Rerogo [~arbrock@chryseis.square1tech.com] has joined #shadows-of-fl
# 2017-01-05 19:14 -0600-!- Irssi: #shadows-of-fl: Total of 2 nicks [0 ops, 0 halfops, 0 voices, 2 normal]
# 2017-01-05 19:14 -0600-!- Irssi: Join to #shadows-of-fl was synced in 4 secs
# --- Day changed Mon Jan 09 2017
# 2017-01-09 23:29 -0600-!- Inglorion [~inglorion@c-76-126-113-28.hsd1.ca.comcast.net] has joined #shadows-of-fl
#
# Basically, this will keep a running count of the current day and translate
# the timestamps to have days and timezones in them, generally assuming that
# the previous timestamps were GMT. This is not a perfect solution, but it's
# close enough for government work. This will ease the transition to
# energymech/znc logging from irssi logging.

use strict;

my %months = ('Jan' => '01',
              'Feb' => '02',
              'Mar' => '03',
              'Apr' => '04',
              'May' => '05',
              'Jun' => '06',
              'Jul' => '07',
              'Aug' => '08',
              'Sep' => '09',
              'Oct' => '10',
              'Nov' => '11',
              'Dec' => '12');

my $filename = shift @ARGV;
if ($filename eq "") {
  die "Usage: $0 <in-file>\n";
}

open(my $fh, "<", $filename) or die "Could not open file $filename.\n";

my $month, my $day, my $year;
while(my $line = <$fh>) {
  if($line =~ /Log opened (Sun|Mon|Tues|Wed|Thu|Fri|Sat) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d\d) \d\d:\d\d:\d\d (\d{4})/) {
    $month = $months{$2};
    $day = $3;
    $year = $4;
    print $line;
  } elsif ($line =~ /Day changed (Sun|Mon|Tues|Wed|Thu|Fri|Sat) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d\d) (\d{4})/) {
    $month = $months{$2};
    $day = $3;
    $year = $4;
    print $line;
  } elsif ($line =~ /\d{4}-\d\d-\d\d \d\d:\d\d -\d{4}-!-.*/) {
    # the rest of the file has good timestamps
    print $line;
    last;
  } else {
    # regular line
    $line =~ /(\d\d):(\d\d) (.*)/;
    my $hour = $1;
    my $minute = $2;
    my $rest = $3;
    print "$year-$month-$day $hour:$minute -0000-!- $rest\n";
  }
}

while(my $line = <$fh>) {
  print $line;
}
