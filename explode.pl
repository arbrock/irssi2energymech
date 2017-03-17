#!/usr/bin/perl

# Convert a non-rotated irssi log into a directory of rotated energymech logs
#
# Have:
# --- Log opened Wed Mar 15 17:41:27 2017
# 2017-03-15 17:41 -0500<arbrock> (but actually I think I'm more likely to see azl living with me than with my sister)
# 2017-03-15 17:41 -0500<ElenaKarras> Yeah
# 2017-03-15 17:44 -0500<arbrock> "7.8% from ages 18-24" welp, she's definitely a demographic match for the county...
# 2017-03-15 17:44 -0500<arbrock> err, town
# --- Log closed Wed Mar 15 17:49:17 2017
#
# Goal:
# [root@chryseis #felines-lair]# cat 2016-12-09.log
# [10:47:02] <dancer> chocolate mixed with chili pepper
# [10:47:06] * dancer purrs
# [15:37:26] *** Joins: Ralas (~BobArctor@76-198-134-111.lightspeed.sntcca.sbcglobal.net)
# [15:37:26] *** ChanServ sets mode: +v Ralas
# [17:44:21] *** Quits: Inglorion (~inglorion@c-76-126-113-28.hsd1.ca.comcast.net) (Ping timeout: 248 seconds)
# [17:51:45] *** Joins: Inglorion (~inglorion@c-76-126-113-28.hsd1.ca.comcast.net)
# [19:03:31] *** Ralas is now known as Ralas|afk

my $filename = shift @ARGV;
if ($filename eq "") {
  die "Usage: $0 <in-file>\n";
}

open(my $fh, "<", $filename) or die "Could not open file $filename.\n";
$filename =~ /(.+).log/;
my $basename = $1;
mkdir($basename) && chdir($basename) || die "Could not mkdir/chdir to $basename.\n";

my $dfh; my $dfname = "";
my $last_timei = ""; my $fake_seconds = 0;

while(my $line = <$fh>) {
  if ($line =~ /(\d{4}-\d\d-\d\d) (\d\d:\d\d) -\d{4}-!-\s+(.*)/) {
      # a regular text line: since we are running after augment, it has all the data we need
      my $curr_date = $1;
      my $curr_time = $2;
      my $text = $3;
      if(not $curr_date eq $dfname) {
        # need to change files
        close($dfh);
        open($dfh, ">>", $curr_date);
        $dfname = $curr_date;
      }
      # irssi doesn't log seconds, so we need to synthetically generate them
      # We increment seconds to well-order the events
      if($curr_time eq $last_time) {
        $fake_seconds++;
        if($fake_seconds >= 60) {
          warn "More than 60 messages in a minute at $basename:$dfname:$last_time.\n";
        }
      } else {
        $last_time = $curr_time;
        $fake_seconds = 0;
      }
      my $pretty_seconds = sprintf("%02d", $fake_seconds);
      print $dfh "[$curr_time:$pretty_seconds] $text\n";
  }
}

close $dfh;
