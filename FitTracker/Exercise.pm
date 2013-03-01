package FitTracker::Exercise;
require Exporter;

our @ISA     = qw( Exporter );
our $VERSION = 1.00;

use strict;
use DBI;
use FitTracker::DataAccess;
use FitTracker::Exercise;

my $DATAACCESS = 'FitTracker::DataAccess';
my $EXERCISE = 'FitTracker::Exercise';

sub new {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{NAME}              = shift;
	$self->{CALORIES_PER_HOUR} = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      = "SELECT ID FROM EXERCISES WHERE NAME = '" . $self->{NAME} . "';";
	my $resultSet = $database->selectall_arrayref($sql);

	if ( @$resultSet > 0 ) {

	 # IF THERE IS ALREADY AN EXCERCISE WITH THIS NAME, UPDATE IT
	 	$self->{ID} = (@$resultSet)[0]->[0];
		$sql = " UPDATE EXERCISES SET CALORIES_PER_HOUR = " . $self->{CALORIES_PER_HOUR} . " WHERE ID = " . $self->{ID} . ";";
		$database->do($sql);
	}
	else {

		# OTHERWISE, INSERT NEW RECORD
		$sql = " INSERT INTO EXERCISES( NAME, CALORIES_PER_HOUR ) VALUES( '" . $self->{NAME} . "', " . $self->{CALORIES_PER_HOUR} . ");";
		$database->do($sql);
		$self->{ID} = $database->func('last_insert_rowid');
	}
	return $self;
}

sub copy {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{ID} = shift;
	$self->{NAME}    = shift;
	$self->{CALORIES_PER_HOUR}  = shift;
	return $self;
}

sub getById {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{ID} = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT ID, NAME, CALORIES_PER_HOUR FROM EXERCISES WHERE ID = " . $self->{ID} . ";";
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		$self->{NAME}           = $_->[1];
		$self->{CALORIES_PER_HOUR} = $_->[2];
	}
	return $self;
}

sub getByName {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{NAME} = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT ID, NAME, CALORIES_PER_HOUR FROM EXERCISES WHERE NAME = '" . $self->{NAME} . "';";
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		$self->{ID}           = $_->[0];
		$self->{CALORIES_PER_HOUR} = $_->[2];
	}
	return $self;
}

sub getAll {
	my @exercises;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	  "SELECT ID, NAME, CALORIES_PER_HOUR FROM EXERCISES WHERE HIDDEN = 'FALSE' ORDER BY NAME;";
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		push @exercises, $EXERCISE->copy( $_->[0], $_->[1], $_->[2] );
	}
	return @exercises;
}

sub delete {
	my $self     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      = "DELETE FROM EXERCISES WHERE ID = " . $self->getId() . ";";
	$database->do($sql);
}

sub getId {
	my $self = shift;
	return $self->{ID};
}

sub getName {
	my $self = shift;
	return $self->{NAME};
}

sub getCaloriesPerHour {
	my $self = shift;
	return $self->{CALORIES_PER_HOUR};
}

1;
