#!/usr/bin/perl
#static-index-ls v0.0000, recursively adds index.html to directories
#GNU General Public License 2 or later, copyright 2016 jonpatterns
#the line  <!- static-index-ls -> is added, if an index.html already exist without this line the file isn't altered
#use ls - does not index hidden files or index.html

use strict;
use warnings;
use feature qw(say switch);

##constants
use constant FALSE => 1==0;
use constant TRUE => not FALSE;

#initialise
my @dirtbl = (); 
my @dirnametbl = (); 
my $rootname= '/'; #name for html title
my $curdir = './'; #default to current directory

###check if directory specified  from args

if (@ARGV < 1) {say "Using current directory.";}
else{
	if (!-e $ARGV[0]) {say "Directory '$ARGV[0]' not found."; exit;}
	if (!-d $ARGV[0]) {say "'$ARGV[0]' is not a directory."; exit;}
	$curdir=$ARGV[0];
	#ensure directory ends with char  /
	if (!(substr ($curdir, -1, 1) eq "/")){$curdir = $curdir."/"} ; 
}

##add first directory to table
push @dirtbl, $curdir;
push @dirnametbl, $rootname;

##process directories (processdir adds an directories its comes across to list)
while (@dirtbl){
	processdir (\@dirtbl, \@dirnametbl);
}

exit;

##process next directory on passed arrays (directory table, directory name table)
sub processdir {
	##initialise (local array empty on call)
	my $dir; my $name; my $handle; my $indextrue; my $cmd; my $cnt; my $curfile;
	my $ls = (); my @indexmk = (); my @bash = ();
 	
	##pop directory and name from array passed
	$dir = pop @{$_[0]};
	$name = pop @{$_[1]};
	say "Processing '$name' dir '$dir'";

	##check whether to make index.html or just scan for directories
	if ( -e $dir."index.html") {
		#test if index.html was made with static-index-ls using grep, if not don't overwrite (indextrue = FALSE)
		$cmd ="cat '".$dir."index.html' | grep '<!- static-index-ls ->'";
		@bash = `$cmd`;    
		chomp @bash;
		if (@bash) {$indextrue = TRUE;} else {$indextrue = FALSE;}
	} else {
		#index.hmtl not present okay to make
		$indextrue = TRUE;
	}

	##make header in array if indextrue
	if ($indextrue == TRUE) {
		push @indexmk, "<!DOCTYPE html>";
		push @indexmk, "<html>";
		push @indexmk, "<!- static-index-ls ->";
		push @indexmk, "<head>";
		push @indexmk, "<title>".$name."</title>";
		push @indexmk, "</head>";
		push @indexmk, "<body>";
		push @indexmk, "<h1>Index of '".$name."'</h1>";
		if (!($name eq "/")) {push @indexmk, "<p><a href=\"../index.html\">..</a></p>" ; }
	}
		
	##loop through directory ls listing
	$cmd="ls -1 --file-type '".$dir."'";
	@bash = `$cmd`;    
	chomp @bash;

	for $cnt (0 .. $#bash){
		$curfile = $bash[$cnt];
		##if directory (already includes / at end)
		#push to list
		if ( -d $dir.$curfile ) {
			push @{$_[0]}, $dir.$curfile;
			push @{$_[1]}, $name.$curfile;
			#if index true push line 
			if ($indextrue == TRUE) {push @indexmk, "<p><a href=\"".$curfile."index.html\">".$curfile."</a></p>" ;}
		} else {
			##file 
			#if index true push line, if not 'index.html'
			if ($indextrue == TRUE) {if (!($curfile eq "index.html")) { push @indexmk, "<p><a href=\"".$curfile."\">".$curfile."</a></p>" ;}}
		}
	}
	
	##make footer and create file if indextrue
	if ($indextrue == TRUE) {
		#footer
		push @indexmk, "</body>";
		push @indexmk, "";
		push @indexmk, "</html>";
		# write array to file - test local array is empty (> overwrite >> append)
		open ($handle, '>', $dir."index.html") or die;
		foreach (@indexmk){ say $handle $_; }
		close $handle;
	}
}

