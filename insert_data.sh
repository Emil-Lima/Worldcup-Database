#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Drop tables if exist
$PSQL "DROP TABLE IF EXISTS games"
$PSQL "DROP TABLE IF EXISTS teams"

# Create table teams
$PSQL "CREATE TABLE teams(team_id SERIAL PRIMARY KEY NOT NULL, name VARCHAR(30) UNIQUE NOT NULL)"

# Create table games
$PSQL "CREATE TABLE games(game_id SERIAL PRIMARY KEY NOT NULL, year INT NOT NULL, round VARCHAR NOT NULL, winner_id INT REFERENCES teams(team_id) NOT NULL, opponent_id INT REFERENCES teams(team_id) NOT NULL, winner_goals INT NOT NULL, opponent_goals INT NOT NULL)"

# Loop through each line in games.csv
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Ignore first line
  if [[ $YEAR != year ]]
  then
    # Insert team into teams database
    # Check if winner in database and opponent in teams database
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # If a team id does not exist, insert that team into the teams database
    if [[ -z $WINNER_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
    fi
    if [[ -z $OPPONENT_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
    fi
    # Insert game into games database
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
  fi
done

# Insert games' data
