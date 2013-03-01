#!C:/Cloud/xampp/perl/bin
use HTML::Mason::CGIHandler;
use CGI qw/:standard/;

my $page = param( 'page' );
if( !defined( $page ) ) {
	$page = 'user';
}
#my $homeDirectory = '/home/steveper/public_html/cgi-bin';
#my $homeDirectory = '/usr/lib/cgi-bin';
my $homeDirectory = 'C:/Cloud/xampp/cgi-bin';

$ENV{PATH_INFO} = '/masoncomponents/' . $page;

my $h = HTML::Mason::CGIHandler->new(
	comp_root => "$homeDirectory",
	data_dir  => "$homeDirectory/masondata"
);    

$h->handle_request;

