package FitTracker::User;
require Exporter;

our @ISA     = qw( Exporter );
our $VERSION = 1.00;

use strict;
use DBI;

use FitTracker::DataAccess;
use FitTracker::Weight;
use FitTracker::Exercise;
use FitTracker::ExercisePerformed;
use FitTracker::Food;
use FitTracker::FoodEaten;

my $DATAACCESS        = 'FitTracker::DataAccess';
my $WEIGHT            = 'FitTracker::Weight';
my $EXERCISE          = 'FitTracker::Exercise';
my $EXERCISEPERFORMED = 'FitTracker::ExercisePerformed';
my $FOOD              = 'FitTracker::Food';
my $FOODEATEN         = 'FitTracker::FoodEaten';
my $USER              = 'FitTracker::User';

sub new {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{NAME}             = shift;
	$self->{GENDER}           = shift;
	$self->{AGE}              = shift;
	$self->{HEIGHT_IN_INCHES} = shift;
	$self->{ACTIVITY_LEVEL}   = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"INSERT INTO USERS(NAME, GENDER, AGE, HEIGHT_IN_INCHES, ACTIVITY_LEVEL) VALUES ('$self->{NAME}', '$self->{GENDER}', $self->{AGE}, $self->{HEIGHT_IN_INCHES}, $self->{ACTIVITY_LEVEL});";
	$database->do($sql);
	$self->{ID} = $database->func('last_insert_rowid');
	return $self;
}

sub copy {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{ID}               = shift;
	$self->{NAME}             = shift;
	$self->{GENDER}           = shift;
	$self->{AGE}              = shift;
	$self->{HEIGHT_IN_INCHES} = shift;
	$self->{ACTIVITY_LEVEL}   = shift;
	return $self;
}

sub getById {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	$self->{ID} = shift;
	my $database = $DATAACCESS->getDatabaseConnection();    
	my $sql      =
"SELECT ID, NAME, GENDER, AGE, HEIGHT_IN_INCHES, ACTIVITY_LEVEL FROM USERS WHERE ID = "
	  . $self->{ID} . ";";
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		$self->{NAME}             = $_->[1];
		$self->{GENDER}           = $_->[2];
		$self->{AGE}              = $_->[3];
		$self->{HEIGHT_IN_INCHES} = $_->[4];
		$self->{ACTIVITY_LEVEL}   = $_->[5];
	}
	return $self;
}

sub getAll {
	my @users;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
"SELECT ID, NAME, GENDER, AGE, HEIGHT_IN_INCHES, ACTIVITY_LEVEL FROM USERS;";
	my $resultSet = $database->selectall_arrayref($sql);
	foreach (@$resultSet) {
		push @users,
		  $USER->copy( $_->[0], $_->[1], $_->[2], $_->[3], $_->[4], $_->[5] );
	}
	return @users;
}

sub update {
	my $self = shift;
	$self->{NAME}             = shift;
	$self->{GENDER}           = shift;
	$self->{AGE}              = shift;
	$self->{HEIGHT_IN_INCHES} = shift;
	$self->{ACTIVITY_LEVEL}   = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	    "UPDATE USERS SET NAME = '"
	  . $self->{NAME}
	  . "', GENDER = '"
	  . $self->{GENDER}
	  . "', AGE = "
	  . $self->{AGE}
	  . ", HEIGHT_IN_INCHES = "
	  . $self->{HEIGHT_IN_INCHES}
	  . ", ACTIVITY_LEVEL = "
	  . $self->{ACTIVITY_LEVEL}
	  . " WHERE ID = "
	  . $self->getId() . ";";
	$database->do($sql);
	return $self;
}

sub delete {
	my $self     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      = "DELETE FROM USERS WHERE ID = " . $self->getId() . ";";
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

sub getGender {
	my $self = shift;
	return $self->{GENDER};
}

sub getAge {
	my $self = shift;
	return $self->{AGE};
}

sub getHeightInInches {
	my $self = shift;
	return $self->{HEIGHT_IN_INCHES};
}

sub getActivityLevel {

	# NOTE - Acceptable values are:
	# 1.25 - Sedentary
	# 1.3 - Lightly Active
	# 1.5 - Moderately Active
	# 1.7 - Very Active
	# 2.0 - Extremely Active
	my $self = shift;
	return $self->{ACTIVITY_LEVEL};
}

sub addWeight {
	my $self   = shift;
	my $date   = shift;
	my $pounds = shift;
	my $weight = $WEIGHT->new( $self->getId(), $date, $pounds );
}

sub getWeights {
	my $self      = shift;
	my $startDate = shift;
	my $endDate   = shift;
	my $database  = $DATAACCESS->getDatabaseConnection();
	my $sql       =
	  "SELECT USER_ID, DATE, POUNDS FROM WEIGHT WHERE USER_ID = "
	  . $self->getId();
	if ( defined($startDate) && defined($endDate) ) {

# IF START AND END DATES ARE PROVIDED, THEN RETURN WEIGHTS FROM ONLY THAT DATE RANGE
		$sql .= " AND DATE >= '$startDate' AND DATE <= '$endDate';";
	}
	else {

		# OTHERWISE RETURN ALL WEIGHT MEASUREMENTS FOR ALL DATES
		$sql .= ";";
	}
	my $resultSet = $database->selectall_arrayref($sql);
	my @weights;
	foreach (@$resultSet) {
		push @weights, $WEIGHT->copy( $_->[0], $_->[1], $_->[2] );
	}
	return @weights;
}

sub getCurrentWeight {
	my $self     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	  "SELECT USER_ID, max(DATE), POUNDS FROM WEIGHT WHERE USER_ID = "
	  . $self->getId() . ";";
	my $resultSet = $database->selectall_arrayref($sql);
	my @weights;
	foreach (@$resultSet) {
		return $WEIGHT->copy( $_->[0], $_->[1], $_->[2] );
	}
}

sub getWeightOnDate {
	my $self     = shift;
	my $date     = shift;
	my $database = $DATAACCESS->getDatabaseConnection();
	my $sql      =
	  "SELECT USER_ID, max(DATE), POUNDS FROM WEIGHT WHERE USER_ID = "
	  . $self->getId() . " AND DATE <= '$date';";
	my $resultSet = $database->selectall_arrayref($sql);
	my @weights;
	foreach (@$resultSet) {
		return $WEIGHT->copy( $_->[0], $_->[1], $_->[2] );
	}
}

sub getBMI {
	my $self = shift;
	my $pounds = $self->getCurrentWeight()->getPounds();
	my $inches = $self->getHeightInInches();
	return ($pounds * 703) / ($inches * $inches);
}

sub addExercisePerformed {
	my $self             = shift;
	my $exercise         = shift;
	my $date             = shift;
	my $minutes          = shift;
	my $exercisePerfomed =
	  $EXERCISEPERFORMED->new( $self->getId(), $exercise, $date, $minutes );
	return $exercisePerfomed;
}

sub getExercisesPerformed {
	my $self = shift;
	my $date = shift;
	return $EXERCISEPERFORMED->getAll( $self->getId(), $date );
}

sub getExercisesRecentlyPerformed {
	my $self = shift;
	return $EXERCISEPERFORMED->getRecentlyPerformed( $self->getId() );
}

sub addFoodEaten {
	my $self        = shift;
	my $food        = shift;
	my $date        = shift;
	my $servingType = shift;
	my $servingQty  = shift;
	my $foodEaten   =
	  $FOODEATEN->new( $self->getId(), $food, $date, $servingType,
		$servingQty );
	return $foodEaten;
}

sub getFoodsEaten {
	my $self = shift;
	my $date = shift;
	return $FOODEATEN->getAll( $self->getId(), $date );
}

sub getFoodsRecentlyEaten {
	my $self = shift;
	return $FOODEATEN->getRecentlyEaten( $self->getId() );
}

sub getDailyCalorieNeeds {
	my $self        = shift;
	my $centimeters = $self->getHeightInInches() * 2.54;
	my $kilograms   = $self->getCurrentWeight()->getPounds() / 2.2;

	my $adjustedWeight;
	my $adjustedHeight;
	my $adjustedAge;

	if ( $self->getGender() eq "female" ) {
		$adjustedWeight = 655 + ( 9.6 * $kilograms );
		$adjustedHeight = 1.7 * $centimeters;
		$adjustedAge    = 4.7 * $self->getAge();
	}
	else {

		# male
		$adjustedWeight = 66 + ( 13.7 * $kilograms );
		$adjustedHeight = 5 * $centimeters;
		$adjustedAge    = 6.8 * $self->getAge();
	}
	return
	  int( ( $adjustedWeight + $adjustedHeight - $adjustedAge ) *
		  $self->getActivityLevel() );
}

sub getDailyPointsRange {
	my $self        = shift;
	my $points = 0;
	#gender
	if ( $self->getGender() eq "female" ) {
		$points += 2;
	} else {
		# male
		$points += 8;
	}
	#age
	if( $self->getAge() <= 26 ) {
		$points += 4;
	} elsif( $self->getAge() <= 37 ) {
		$points += 3;
	} elsif( $self->getAge() <= 47 ) {
		$points += 2;
	} elsif( $self->getAge() <= 58 ) {
		$points += 1;
	} 
	#current weight
	$points += int( $self->getCurrentWeight()->getPounds() / 10 );
	#height
	if( $self->getHeightInInches() >= 61 && $self->getHeightInInches() <= 70 ) {
		$points += 1;
	} elsif( $self->getHeightInInches() > 70 ) {
		$points += 2;
	}
	#activity level
	if( $self->getActivityLevel() == 1.3 ) {
		#lightly active
		$points += 2;
	} elsif( $self->getActivityLevel() == 1.5 ) {
		#moderately active
		$points += 4;
	} elsif( $self->getActivityLevel() >= 1.7 ) {
		#very active or extemely active
		$points += 6;
	}
	#flex
	$points += 5;
	return $points;
}

sub getExerciseCaloriesForDay {
	my $self = shift;
	my $date = shift;
	my $totalCalories;
	my @exercisesPerformed = $self->getExercisesPerformed( "$date" );
	for( my $index = 0; $index < @exercisesPerformed; $index++ ) {
		my $exercisePerformed = $exercisesPerformed[$index];		
		$totalCalories += $exercisePerformed->getCalories();
	}
	return $totalCalories;
}

sub getExercisePointsForDay {
	my $self = shift;
	my $date = shift;
	my $totalPoints;
	my @exercisesPerformed = $self->getExercisesPerformed( "$date" );
	for( my $index = 0; $index < @exercisesPerformed; $index++ ) {
		my $exercisePerformed = $exercisesPerformed[$index];		
		$totalPoints += $exercisePerformed->getPoints();
	}
	return $totalPoints;
}

sub getCaloriesForDay {
	my $self = shift;
	my $date = shift;
	my $totalCalories;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalCalories += $foodEaten->getCalories();
	}
	return $totalCalories;
}

sub getProteinForDay {
	my $self = shift;
	my $date = shift;
	my $totalProtein;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalProtein += $foodEaten->getProtein();
	}
	return $totalProtein;
}

sub getFatForDay {
	my $self = shift;
	my $date = shift;
	my $totalFat;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalFat += $foodEaten->getFat();
	}
	return $totalFat;
}

sub getSaturatedFatForDay {
	my $self = shift;
	my $date = shift;
	my $totalSatFat;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalSatFat += $foodEaten->getSaturatedFat();
	}
	return $totalSatFat;
}

sub getCarbsForDay {
	my $self = shift;
	my $date = shift;
	my $totalCarbs;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalCarbs += $foodEaten->getCarbs();
	}
	return $totalCarbs;
}

sub getFiberForDay {
	my $self = shift;
	my $date = shift;
	my $totalFiber;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalFiber += $foodEaten->getFiber();
	}
	return $totalFiber;
}

sub getSugarForDay {
	my $self = shift;
	my $date = shift;
	my $totalSugar;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalSugar += $foodEaten->getSugar();
	}
	return $totalSugar;
}

sub getSodiumForDay {
	my $self = shift;
	my $date = shift;
	my $totalSodium;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalSodium += $foodEaten->getSodium();
	}
	return $totalSodium;
}

sub getPointsForDay {
	my $self = shift;
	my $date = shift;
	my $totalPoints;
	my @foodsEaten = $self->getFoodsEaten( "$date" );
	for( my $index = 0; $index < @foodsEaten; $index++ ) {
		my $foodEaten = $foodsEaten[$index];		
		$totalPoints += $foodEaten->getPoints();
	}
	return $totalPoints;
}

1;
