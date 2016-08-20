#!/usr/bin/perl
#### pmount-lvm-all v0.000 experimental
#### script to all mount lv (logical volumes), after they have been initialised
## script fails if not root user

use strict;
use warnings;

###initialise variables
my $cnt;
my $str;

###initialise lv
#put plvm-initialise in ~/Startup - it executes:
#dmsetup mknodes, vgscan --ignorelockingfailure and vgchange -ay --ignorelockingfailure
#that activates lv at /dev/mapper/<vg_name>-<lv_name>

###mkdir and mount for each lv
#get lv lists from `lvs`, with the format <vg_name>-<lv_name>
my @lvpara = `lvs --noheadings --separator '-' -o vg_name,lv_name`;    
chomp @lvpara;

#process each lv ($#lvpara is position of last entry (starting 0) -1 is empty
#might clash if something else is already mounted at /mnt/<vg_name>-<lv_name> (perhaps unlikely)
for $cnt (0 .. $#lvpara) {
    $lvpara[$cnt] =~ s/^\s+//; #next lv str, left trim white space
	$str = $lvpara[$cnt]; #next lv str -> str
	mkdir("/mnt/".$str) unless (-d "/mnt/".$str); #mkdir unless it exists, (works with space in name)
	`mount '/dev/mapper/$str' '/mnt/$str' \n`; #mount lv from /dev/mapper
}

exit;
