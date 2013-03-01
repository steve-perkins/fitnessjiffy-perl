package FitTracker::Weight;
require Exporter;

our @ISA     = qw( Exporter );
our $VERSION = 1.00;

use strict;
use DBI;
use FitTracker::DataAccess;

my $DATAACCESS = 'FitTracker::DataAccess';

sub new {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID} = shift;
	$self->{DATE}    = shift;
	$self->{POUNDS}  = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql =
	    "SELECT USER_ID, DATE, POUNDS FROM WEIGHT WHERE USER_ID = "
	  . $self->{USER_ID}
	  . " AND DATE = '"
	  . $self->{DATE} . "';";
	my $resultSet = $database->selectall_arrayref($sql);

	if ( @$resultSet > 0 ) {
		if ( defined( $self->{POUNDS} ) && $self->{POUNDS} != 0 ) {
	 # IF THERE IS ALREADY A WEIGHT RECORD FOR THIS USER ON THIS DATE, UPDATE IT
			$sql =
			    "UPDATE WEIGHT SET POUNDS = "
			  . $self->{POUNDS}
			  . " WHERE USER_ID = "
			  . $self->{USER_ID}
			  . " AND DATE = '"
			  . $self->{DATE} . "';";
			$database->do($sql);
		}
		else {

 # USER IS UPDATING WITH A NULL WEIGHT VALUE.  DELETE ANY EXISTING ROWS FOR THIS
 # USER ON THIS DATE
			$sql =
			    "DELETE FROM WEIGHT WHERE USER_ID = "
			  . $self->{USER_ID}
			  . " AND DATE = '"
			  . $self->{DATE} . "';";
			$database->do($sql);
			return undef;    
		}
	}
	else {

		# OTHERWISE, INSERT NEW RECORD
		$sql =
		    "INSERT INTO WEIGHT (USER_ID, DATE, POUNDS) VALUES ("
		  . $self->{USER_ID} . ", '"
		  . $self->{DATE} . "', "
		  . $self->{POUNDS} . ");";
		$database->do($sql);
	}
	return $self;
}

sub copy {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID} = shift;
	$self->{DATE}    = shift;
	$self->{POUNDS}  = shift;
	return $self;
}

sub getByPrimaryKey {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID} = shift;
	$self->{DATE}    = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT USER_ID, DATE, POUNDS FROM WEIGHT WHERE USER_ID = "
	  . $self->{USER_ID}
	  . " AND DATE = '"
	  . $self->{DATE} . "';";
	my $resultSet = $database->selectall_arrayref($sql);

	foreach (@$resultSet) {
		$self->{POUNDS} = $_->[2];
	}
	return $self;
}

sub getUserId {
	my $self = shift;
	return $self->{USER_ID};
}

sub getDate {
	my $self = shift;
	return $self->{DATE};
}

sub getPounds {
	my $self = shift;
	return $self->{POUNDS};
}

1;
