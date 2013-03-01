package FitTracker::Food;
require Exporter;

our @ISA     = qw( Exporter );
our $VERSION = 1.00;

use strict;
use DBI;
use FitTracker::DataAccess;
use FitTracker::Exercise;

my $DATAACCESS = 'FitTracker::DataAccess';
my $EXERCISE   = 'FitTracker::Exercise';
my $FOOD       = 'FitTracker::Food';

sub new {
    my $class = shift;
    my $self  = {};
    bless( $self, $class );
    $self->{NAME}                 = shift;
    $self->{DEFAULT_SERVING_TYPE} = shift;
    $self->{SERVING_TYPE_QTY}     = shift;
    $self->{CALORIES}             = shift;
    $self->{FAT}                  = shift;
    $self->{SATURATED_FAT}        = shift;
    $self->{CARBS}                = shift;
    $self->{FIBER}                = shift;
    $self->{SUGAR}                = shift;
    $self->{PROTEIN}              = shift;
    $self->{SODIUM}               = shift;
    my $database = $DATAACCESS->getDatabaseConnection();
    my $sql      = "SELECT ID FROM FOODS WHERE NAME = '" . $self->{NAME} . "';";
    my $resultSet = $database->selectall_arrayref($sql);

    if ( @$resultSet > 0 ) {

        # IF THERE IS ALREADY AN FOOD WITH THIS NAME, UPDATE IT
        $self->{ID} = (@$resultSet)[0]->[0];
        $sql =
            " UPDATE FOODS SET DEFAULT_SERVING_TYPE = '"
          . $self->{DEFAULT_SERVING_TYPE}
          . "', SERVING_TYPE_QTY = "
          . $self->{SERVING_TYPE_QTY}
          . ", CALORIES = "
          . $self->{CALORIES}
          . ", FAT = "
          . $self->{FAT}
          . ", SATURATED_FAT = "
          . $self->{SATURATED_FAT}
          . ", CARBS = "
          . $self->{CARBS}
          . ", FIBER = "
          . $self->{FIBER}
          . ", SUGAR = "
          . $self->{SUGAR}
          . ", PROTEIN = "
          . $self->{PROTEIN}
          . ", SODIUM = "
          . $self->{SODIUM}
          . " WHERE ID = "
          . $self->{ID} . ";";
        $database->do($sql);
    }
    else {

        # OTHERWISE, INSERT NEW RECORD
        $sql =
"INSERT INTO FOODS( NAME, DEFAULT_SERVING_TYPE, SERVING_TYPE_QTY, CALORIES, FAT, SATURATED_FAT, CARBS, FIBER, SUGAR, PROTEIN, SODIUM ) VALUES( '"
          . $self->{NAME} . "', '"
          . $self->{DEFAULT_SERVING_TYPE} . "', "
          . $self->{SERVING_TYPE_QTY} . ", "
          . $self->{CALORIES} . ", "
          . $self->{FAT} . ", "
          . $self->{SATURATED_FAT} . ", "
          . $self->{CARBS} . ", "
          . $self->{FIBER} . ", "
          . $self->{SUGAR} . ", "
          . $self->{PROTEIN} . ", "
          . $self->{SODIUM} . ");";
        $database->do($sql);
        $self->{ID} = $database->func('last_insert_rowid');
    }
    return $self;
}

sub copy {
    my $class = shift;
    my $self  = {};
    bless( $self, $class );
    $self->{ID}                   = shift;
    $self->{NAME}                 = shift;
    $self->{DEFAULT_SERVING_TYPE} = shift;
    $self->{SERVING_TYPE_QTY}     = shift;
    $self->{CALORIES}             = shift;
    $self->{FAT}                  = shift;
    $self->{SATURATED_FAT}        = shift;
    $self->{CARBS}                = shift;
    $self->{FIBER}                = shift;
    $self->{SUGAR}                = shift;
    $self->{PROTEIN}              = shift;
    $self->{SODIUM}               = shift;
    return $self;
}

sub getById {
    my $class = shift;
    my $self  = {};
    bless( $self, $class );
    $self->{ID} = shift;
    my $database = $DATAACCESS->getDatabaseConnection();
    my $sql      =
"SELECT ID, NAME, DEFAULT_SERVING_TYPE, SERVING_TYPE_QTY, CALORIES, FAT, SATURATED_FAT, CARBS, FIBER, SUGAR, PROTEIN, SODIUM FROM FOODS WHERE ID = "
      . $self->{ID} . ";";
    my $resultSet = $database->selectall_arrayref($sql);
    foreach (@$resultSet) {
        $self->{NAME}                 = $_->[1];
        $self->{DEFAULT_SERVING_TYPE} = $_->[2];
        $self->{SERVING_TYPE_QTY}     = $_->[3];
        $self->{CALORIES}             = $_->[4];
        $self->{FAT}                  = $_->[5];
        $self->{SATURATED_FAT}        = $_->[6];
        $self->{CARBS}                = $_->[7];
        $self->{FIBER}                = $_->[8];
        $self->{SUGAR}                = $_->[9];
        $self->{PROTEIN}              = $_->[10];
        $self->{SODIUM}               = $_->[11];
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
"SELECT ID, NAME, DEFAULT_SERVING_TYPE, SERVING_TYPE_QTY, CALORIES, FAT, SATURATED_FAT, CARBS, FIBER, SUGAR, PROTEIN, SODIUM FROM FOODS WHERE NAME = '"
      . $self->{NAME} . "';";
    my $resultSet = $database->selectall_arrayref($sql);
    foreach (@$resultSet) {
        $self->{ID}                   = $_->[0];
        $self->{DEFAULT_SERVING_TYPE} = $_->[2];
        $self->{SERVING_TYPE_QTY}     = $_->[3];
        $self->{CALORIES}             = $_->[4];
        $self->{FAT}                  = $_->[5];
        $self->{SATURATED_FAT}        = $_->[6];
        $self->{CARBS}                = $_->[7];
        $self->{FIBER}                = $_->[8];
        $self->{SUGAR}                = $_->[9];
        $self->{PROTEIN}              = $_->[10];
        $self->{SODIUM}               = $_->[11];
    }
    return $self;
}

sub getAll {
    my @foods;
    my $database = $DATAACCESS->getDatabaseConnection();
    my $sql      =
"SELECT ID, NAME, DEFAULT_SERVING_TYPE, SERVING_TYPE_QTY, CALORIES, FAT, SATURATED_FAT, CARBS, FIBER, SUGAR, PROTEIN, SODIUM FROM FOODS ORDER BY NAME;";
    my $resultSet = $database->selectall_arrayref($sql);
    foreach (@$resultSet) {
        push @foods,
          $FOOD->copy(
            $_->[0], $_->[1], $_->[2], $_->[3], $_->[4],  $_->[5],
            $_->[6], $_->[7], $_->[8], $_->[9], $_->[10], $_->[11]
          );
    }
    return @foods;
}

sub getAllMatchingName {
	my $class = shift;
    my $searchName = shift;
    my @foods;
    my $database = $DATAACCESS->getDatabaseConnection();
    my $sql = "SELECT ID, NAME, DEFAULT_SERVING_TYPE, SERVING_TYPE_QTY, CALORIES, FAT, SATURATED_FAT, CARBS, FIBER, SUGAR, PROTEIN, SODIUM FROM FOODS "
		. "WHERE NAME LIKE '%" . $searchName . "%' ORDER BY NAME;";
	print STDERR "$sql\n"; 
    my $resultSet = $database->selectall_arrayref($sql);
    foreach (@$resultSet) {
        push @foods,
          $FOOD->copy(
            $_->[0], $_->[1], $_->[2], $_->[3], $_->[4],  $_->[5],
            $_->[6], $_->[7], $_->[8], $_->[9], $_->[10], $_->[11]
          );
    }
    return @foods;
}

sub delete {
    my $self     = shift;
    my $database = $DATAACCESS->getDatabaseConnection();
    my $sql      = "DELETE FROM FOODS WHERE ID = " . $self->getId() . ";";
    $database->do($sql);
    my $sql      = "DELETE FROM FOODS_EATEN WHERE FOOD_ID = " . $self->getId() . ";";
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

sub getDefaultServingType {
    my $self = shift;
    return $self->{DEFAULT_SERVING_TYPE};
}

sub getServingTypeQty {
    my $self = shift;
    return $self->{SERVING_TYPE_QTY};
}

sub getCalories {
    my $self = shift;
    return $self->{CALORIES};
}

sub getFat {
    my $self = shift;
    return $self->{FAT};
}

sub getSaturatedFat {
    my $self = shift;
    return $self->{SATURATED_FAT};
}

sub getCarbs {
    my $self = shift;
    return $self->{CARBS};
}

sub getFiber {
    my $self = shift;
    return $self->{FIBER};
}

sub getSugar {
    my $self = shift;
    return $self->{SUGAR};
}

sub getProtein {
    my $self = shift;
    return $self->{PROTEIN};
}

sub getSodium {
    my $self = shift;
    return $self->{SODIUM};
}

sub getPoints {
    my $self = shift;
	my $fiber = $self->{FIBER};
	if( $fiber > 4 ) { $fiber = 4 };
	my $points = ( ($self->{CALORIES} / 50) + ($self->{FAT} / 12) - ($fiber / 5) );
	if( $points > 0 ) {
		return $points;
	} else {
		return 0;
	}
}

sub getAvailableServingTypes {
    my $self = shift;
    my @availableTypes;
    if ( $self->getDefaultServingType() eq "CUSTOM" ) {
        push @availableTypes, "CUSTOM";
        return @availableTypes;
    }
    else {
        my $database  = $DATAACCESS->getDatabaseConnection();
        my $sql       = "SELECT DISTINCT NAME FROM SERVING_TYPES;";
        my $resultSet = $database->selectall_arrayref($sql);
        foreach (@$resultSet) {
            push @availableTypes, $_->[0];
        }
    }
    return @availableTypes;
}

1;
