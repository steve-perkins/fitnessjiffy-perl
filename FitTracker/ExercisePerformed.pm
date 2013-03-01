package FitTracker::ExercisePerformed;
require Exporter;

our @ISA     = qw( Exporter );
our $VERSION = 1.00;

use strict;
use DBI;
use FitTracker::DataAccess;
use FitTracker::Exercise;

my $DATAACCESS = 'FitTracker::DataAccess';
my $EXERCISE = 'FitTracker::Exercise';
my $EXERCISEPERFORMED = 'FitTracker::ExercisePerformed';
my $USER = 'FitTracker::User';

sub new {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID}  = shift;
	$self->{EXERCISE} = shift;
	$self->{DATE}     = shift;
	$self->{MINUTES}  = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	    "SELECT * FROM EXERCISES_PERFORMED WHERE USER_ID = "
	  . $self->{USER_ID}
	  . " AND EXERCISE_ID = "
	  . $self->{EXERCISE}->getId()
	  . " AND DATE = '"
	  . $self->{DATE} . "';";
	my $resultSet = $database->selectall_arrayref($sql);

	if ( @$resultSet > 0 ) {

	  # IF THIS USER HAS ALREADY PERFORMED THIS EXERCISE ON THIS DATE, UPDATE IT
		$sql =
		    " UPDATE EXERCISES_PERFORMED SET MINUTES = "
		  . $self->{MINUTES}
		  . " WHERE USER_ID = "
		  . $self->{USER_ID}
		  . " AND EXERCISE_ID = "
		  . $self->{EXERCISE}->getId()
		  . " AND DATE = '"
		  . $self->{DATE} . "';";
		$database->do($sql);
	}
	else {

		# OTHERWISE, INSERT NEW RECORD
		$sql =
" INSERT INTO EXERCISES_PERFORMED( USER_ID, EXERCISE_ID, DATE, MINUTES ) VALUES( "
		  . $self->{USER_ID} . ", "
		  . $self->{EXERCISE}->getId() . ", '"
		  . $self->{DATE} . "', "
		  . $self->{MINUTES} . ");";
		$database->do($sql);
	}
	return $self;
}

sub copy {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID}  = shift;
	$self->{EXERCISE} = shift;
	$self->{DATE}     = shift;
	$self->{MINUTES}  = shift;
	return $self;
}

sub getAll {
	my $class    = shift;
	my $userId   = shift;
	my $date     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT USER_ID, EXERCISE_ID, DATE, MINUTES FROM EXERCISES_PERFORMED WHERE USER_ID = "
	  . $userId
	  . " AND DATE = '"
	  . $date . "';";
	my @exercisesPerformed;
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		my $exercise = $EXERCISE->getById( $_->[1] );
		push @exercisesPerformed,
		  $EXERCISEPERFORMED->copy( $_->[0], $exercise, $_->[2], $_->[3],
			$_->[4] );
	}
	return @exercisesPerformed;
}

sub getByPrimaryKey {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID} = shift;
	$self->{EXERCISE}    = shift;
	$self->{DATE}    = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT USER_ID, EXERCISE_ID, DATE, MINUTES FROM EXERCISES_PERFORMED WHERE USER_ID = "
	  . $self->{USER_ID}
	  . " AND EXERCISE_ID = "
	  . $self->{EXERCISE}->getId()
	  . " AND DATE = '"
	  . $self->{DATE} . "';";
	my $resultSet = $database->selectall_arrayref($sql);

	foreach (@$resultSet) {
		$self->{MINUTES} = $_->[3];
	}
	return $self;
}

sub delete {
	my $self     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	    "DELETE FROM EXERCISES_PERFORMED WHERE USER_ID = "
	  . $self->getUserId()
	  . " AND EXERCISE_ID = "
	  . $self->getExercise()->getId()
	  . " AND DATE = '"
	  . $self->getDate() . "';";
	$database->do($sql);
}

sub getRecentlyPerformed {
	my $class    = shift;
	my $userId   = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT ID FROM EXERCISES WHERE ID IN (SELECT EXERCISE_ID FROM EXERCISES_PERFORMED WHERE USER_ID = "
	  . $userId
	  . " AND DATE >= date('now', '-7 day') ) AND HIDDEN = 'FALSE' ORDER BY NAME;";
	my @exercisesPerformed;
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		my $exercise = $EXERCISE->getById( $_->[0] );
		push @exercisesPerformed, $exercise;
	}
	return @exercisesPerformed;
}

sub getUserId {
	my $self = shift;
	return $self->{USER_ID};
}

sub getExercise {
	my $self = shift;
	return $self->{EXERCISE};
}

sub getDate {
	my $self = shift;
	return $self->{DATE};
}

sub getMinutes {
	my $self = shift;
	return $self->{MINUTES};
}

sub getCalories {
	my $self     = shift;
	my $calories =
	  $self->getExercise()->getCaloriesPerHour() * ( $self->getMinutes() / 60 );
	return $calories;
}

sub getPoints {
	my $self     = shift;
	my $calories = $self->getExercise()->getCaloriesPerHour();
	my $minutes = $self->getMinutes();
	my $user = $USER->getById( $self->{USER_ID} );
	my $exercise = $self->{EXERCISE};
	my $weight = $user->getWeightOnDate( $self->{DATE} )->getPounds();
	if( $exercise->getCaloriesPerHour() <  400 ) {
		return ($weight * $self->getMinutes() * 0.000232);
	} elsif( $exercise->getCaloriesPerHour() <  900 ) {
		return ($weight * $self->getMinutes() * 0.000327);
	} else {
		return ($weight * $self->getMinutes() * 0.0008077);
	}
}

1;
