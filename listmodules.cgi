#!/usr/bin/perl

#use HTML::Mason::CGIHandler;
use CGI qw/:standard/;

print "Content-type: text/html\n\n";
use ExtUtils::Installed;
my $instmod = ExtUtils::Installed->new();
foreach my $module ($instmod->modules()) {
my $version = $instmod->version($module) || "???";
       print "$module -- $version<br/>\n";
}

use Cwd;
print "cwd() is:\t\t",cwd(),"\n";
