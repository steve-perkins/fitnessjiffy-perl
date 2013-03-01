package FitTracker::FoodEaten;
require Exporter;

our @ISA     = qw( Exporter );
our $VERSION = 1.00;

use strict;
use DBI;
use FitTracker::DataAccess;
use FitTracker::Food;

my $DATAACCESS = 'FitTracker::DataAccess';
my $FOOD       = 'FitTracker::Food';
my $FOODEATEN  = 'FitTracker::FoodEaten';

my $ratio;

sub new {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID}      = shift;    
	$self->{FOOD}         = shift;
	$self->{DATE}         = shift;
	$self->{SERVING_TYPE} = shift;
	$self->{SERVING_QTY}  = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	    "SELECT * FROM FOODS_EATEN WHERE USER_ID = "
	  . $self->{USER_ID}
	  . " AND FOOD_ID = "
	  . $self->{FOOD}->getId()
	  . " AND DATE = '"
	  . $self->{DATE} . "';";
	my $resultSet = $database->selectall_arrayref($sql);

	if ( @$resultSet > 0 ) {

		# IF THIS USER HAS ALREADY EATEN THIS FOOD ON THIS DATE, UPDATE IT
		$sql =
		    " UPDATE FOODS_EATEN SET SERVING_TYPE = '"
		  . $self->{SERVING_TYPE}
		  . "', SERVING_QTY = "
		  . $self->{SERVING_QTY}
		  . " WHERE USER_ID = "
		  . $self->{USER_ID}
		  . " AND FOOD_ID = "
		  . $self->{FOOD}->getId()
		  . " AND DATE = '"
		  . $self->{DATE} . "';";
		$database->do($sql);
	}
	else {

		# OTHERWISE, INSERT NEW RECORD
		$sql =
"INSERT INTO FOODS_EATEN( USER_ID, FOOD_ID, DATE, SERVING_TYPE, SERVING_QTY ) VALUES( "
		  . $self->{USER_ID} . ", "
		  . $self->{FOOD}->getId() . ", '"
		  . $self->{DATE} . "', '"
		  . $self->{SERVING_TYPE} . "', "
		  . $self->{SERVING_QTY} . ");";
		$database->do($sql);
	}
	return $self;
}

sub copy {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID}      = shift;
	$self->{FOOD}         = shift;
	$self->{DATE}         = shift;
	$self->{SERVING_TYPE} = shift;
	$self->{SERVING_QTY}  = shift;
	return $self;
}

sub getByPrimaryKey {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{USER_ID} = shift;
	$self->{FOOD}    = shift;
	$self->{DATE}    = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT USER_ID, FOOD_ID, DATE, SERVING_TYPE, SERVING_QTY FROM FOODS_EATEN WHERE USER_ID = "
	  . $self->{USER_ID}
	  . " AND FOOD_ID = "
	  . $self->{FOOD}->getId()
	  . " AND DATE = '"
	  . $self->{DATE} . "';";
	my $resultSet = $database->selectall_arrayref($sql);

	foreach (@$resultSet) {
		$self->{SERVING_TYPE} = $_->[3];
		$self->{SERVING_QTY}  = $_->[4];
	}
	return $self;
}

sub getAll {
	my $class    = shift;
	my $userId   = shift;
	my $date     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT USER_ID, FOOD_ID, DATE, SERVING_TYPE, SERVING_QTY FROM FOODS_EATEN WHERE USER_ID = "
	  . $userId
	  . " AND DATE = '"
	  . $date . "';";
	my @foodsEaten;
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		my $food = $FOOD->getById( $_->[1] );
		push @foodsEaten,
		  $FOODEATEN->copy( $_->[0], $food, $_->[2], $_->[3], $_->[4] );
	}
	return @foodsEaten;
}

sub getRecentlyEaten {
	my $class    = shift;
	my $userId   = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT ID FROM FOODS WHERE ID IN (SELECT FOOD_ID FROM FOODS_EATEN WHERE USER_ID = "
	  . $userId
	  . " AND DATE >= date('now', '-7 day') ) ORDER BY NAME;";
	my @foods;
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		my $food = $FOOD->getById( $_->[0] );
		push @foods, $food;
	}
	return @foods;
}

sub delete {
	my $self     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	    "DELETE FROM FOODS_EATEN WHERE USER_ID = "
	  . $self->getUserId()
	  . " AND FOOD_ID = "
	  . $self->getFood()->getId()
	  . " AND DATE = '"
	  . $self->getDate() . "';";
	$database->do($sql);
}

sub getUserId {
	my $self = shift;
	return $self->{USER_ID};
}

sub getFood {
	my $self = shift;
	return $self->{FOOD};
}

sub getDate {
	my $self = shift;
	return $self->{DATE};
}

sub getServingType {
	my $self = shift;
	return $self->{SERVING_TYPE};
}

sub getServingQty {
	my $self = shift;
	return $self->{SERVING_QTY};
}

sub getRatio {
	my $self = shift;
	if ( defined( $self->{RATIO} ) ) {
		return $self->{RATIO};
	}
	if ( $self->getServingType() eq $self->getFood()->getDefaultServingType() )
	{

		# NORMAL SERVING TYPE... THIS IS EASY
		$self->{RATIO} =
		  $self->getServingQty() / $self->getFood()->getServingTypeQty();
		return $self->{RATIO};
	}
	else {

		# NEED TO CONVERT BETWEEN TYPES
		my $database = $DATAACCESS->getDatabaseConnection();
		my $sql      =
		  "SELECT NAME, NUM_OF_OUNCES FROM SERVING_TYPES WHERE NAME = '"
		  . $self->getServingType() . "';";
		my $resultSet = $database->selectall_arrayref($sql);
		my $ouncesInThisServingType;
		foreach (@$resultSet) {
			$ouncesInThisServingType = $_->[1];
		}
		$sql =
		  "SELECT NAME, NUM_OF_OUNCES FROM SERVING_TYPES WHERE NAME = '"
		  . $self->getFood()->getDefaultServingType() . "';";
		$resultSet = $database->selectall_arrayref($sql);
		my $ouncesInDeafaultServingType;
		foreach (@$resultSet) {
			$ouncesInDeafaultServingType = $_->[1];
		}
		if (
			$ouncesInDeafaultServingType * $self->getFood()->getServingTypeQty()
			!= 0 )
		{
			$self->{RATIO} =
			  ( $ouncesInThisServingType * $self->getServingQty() ) /
			  ( $ouncesInDeafaultServingType *
				  $self->getFood()->getServingTypeQty() );
		}
		else {
			$self->{RATIO} = 0;
		}
		return $self->{RATIO};
	}
}

sub getCalories {
	my $self = shift;

# CALCULATE CALORIES BASED ON SERVING TYPE AND QTY COMPARED WITH VALUES ACTUALLY USED HERE
# APPLY SAME LOGIC TO RETURN CONVERTED FAT, CARBS, ETC.
	return ( $self->getFood()->getCalories() * $self->getRatio() );
}

sub getFat {
	my $self = shift;
	return ( $self->getFood()->getFat() * $self->getRatio() );
}

sub getSaturatedFat {
	my $self = shift;
	return ( $self->getFood()->getSaturatedFat() * $self->getRatio() );
}

sub getCarbs {
	my $self = shift;
	return ( $self->getFood()->getCarbs() * $self->getRatio() );
}

sub getFiber {
	my $self = shift;
	return ( $self->getFood()->getFiber() * $self->getRatio() );
}

sub getSugar {
	my $self = shift;
	return ( $self->getFood()->getSugar() * $self->getRatio() );
}

sub getProtein {
	my $self = shift;
	return ( $self->getFood()->getProtein() * $self->getRatio() );
}

sub getSodium {
	my $self = shift;
	return ( $self->getFood()->getSodium() * $self->getRatio() );
}

sub getPoints {
	my $self = shift;
	return ( $self->getFood()->getPoints() * $self->getRatio() );
}

1;

