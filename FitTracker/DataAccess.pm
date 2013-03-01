package FitTracker::DataAccess;
require Exporter;

our @ISA     = qw( Exporter );
our @EXPORT  = qw( getDatabaseConnection initializeDatabase closeDatabaseConnection );
our $VERSION = 1.00;

use strict;
use DBI;

my $database;

sub getDatabaseConnection {
	if ( !( defined($database) ) ) {
		if ( -e "data.db" ) {
			$database = DBI->connect("dbi:SQLite:data.db")
			  || die "Cannot connect: $DBI::errstr";
		}
		else {
			$database = DBI->connect("dbi:SQLite:data.db")
			  || die "Cannot connect: $DBI::errstr";
			&initializeDatabase($database);
		}
	}
	return $database;
}

sub initializeDatabase {
	my $database             = $_[0];
	my $createExercisesTable = q/
CREATE TABLE [EXERCISES] (
[ID] INTEGER PRIMARY KEY,
[CALORIES_PER_HOUR] FLOAT  NOT NULL,
[HIDE_ON_LISTS] BOOLEAN DEFAULT 'FALSE' NOT NULL
);
/;
	my $createExercisesPerformedTable = q/
CREATE TABLE [EXERCISES_PERFORMED] (
[USER_ID] INTEGER  NOT NULL,
[EXERCISE_ID] INTEGER  NOT NULL,
[DATE] DATE  NOT NULL,
[MINUTES] INTEGER  NOT NULL,
PRIMARY KEY ([USER_ID],[EXERCISE_ID],[DATE])
);
/;
	my $createFoodsTable = q/
CREATE TABLE [FOODS] (
[ID] INTEGER PRIMARY KEY,
[NAME] VARCHAR(50)  UNIQUE NOT NULL,
[DEFAULT_SERVING_TYPE] VARCHAR(20)  NULL,
[SERVING_TYPE_QTY] FLOAT DEFAULT 1 NULL,
[CALORIES] INTEGER  NOT NULL,
[FAT] FLOAT  NULL,
[SATURATED_FAT] FLOAT  NULL,
[CARBS] FLOAT  NULL,
[FIBER] FLOAT  NULL,
[SUGAR] FLOAT  NULL,
[PROTEIN] FLOAT  NULL,
[SODIUM] FLOAT  NULL
);
/;
	my $createFoodsEatenTable = q/
CREATE TABLE [FOODS_EATEN] (
[USER_ID] INTEGER  NOT NULL,
[FOOD_ID] INTEGER  NOT NULL,
[DATE] DATE  NOT NULL,
[SERVING_TYPE] VARCHAR(20)  NOT NULL,
[SERVING_QTY] FLOAT DEFAULT 1 NOT NULL,
PRIMARY KEY ([USER_ID],[FOOD_ID],[DATE])
);
/;
	my $createServingTypesTable = q/
CREATE TABLE [SERVING_TYPES] (
[NAME] VARCHAR(20)  PRIMARY KEY NULL,
[NUM_OF_OUNCES] FLOAT  NULL
);
/;
	my $createUsersTable = q/
CREATE TABLE [USERS] (
[ID] INTEGER PRIMARY KEY,
[NAME] VARCHAR(50)  NOT NULL,
[GENDER] VARCHAR(7)  NOT NULL,
[AGE] INTEGER  NOT NULL,
[HEIGHT_IN_INCHES] FLOAT  NOT NULL,
[ACTIVITY_LEVEL] FLOAT  NOT NULL
);
/;
	my $createWeightTable = q/
CREATE TABLE [WEIGHT] (
[USER_ID] INTEGER  NOT NULL,
[DATE] DATE  NOT NULL,
[POUNDS] FLOAT  NOT NULL,
PRIMARY KEY ([USER_ID],[DATE])
);
/;
	$database->do($createExercisesTable);
	$database->do($createExercisesPerformedTable);
	$database->do($createFoodsTable);
	$database->do($createFoodsEatenTable);
	$database->do($createServingTypesTable);
	$database->do($createUsersTable);
	$database->do($createWeightTable);

	$database->do(
		"INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('ounce', 1.0);"
	);
	$database->do(
		"INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('cup', 8.0);");
	$database->do(
"INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('pound', 16.0);"
	);
	$database->do(
		"INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('pint', 16.0);"
	);
	$database->do(
"INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('tablespoon', 0.5);"
	);
	$database->do(
"INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('teaspoon', 0.1667);"
	);
	$database->do(
"INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('gram', 0.03527);"
	);
	#$database->do("INSERT INTO SERVING_TYPES (NAME, NUM_OF_OUNCES) VALUES ('CUSTOM SERVING', NULL);");
}

sub closeDatabaseConnection {
	if ( defined($database) ) {
		$database->disconnect;
	}
}

1;
