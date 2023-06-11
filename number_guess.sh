#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres --tuples-only -t --no-align -c"
echo "Enter your username:"
read USER_INPUT

#function to loop through guesses until right one is chosen
function NUMBER_GUESSING() {
  NUMBER_OF_GUESSES=1

  if [[ -z $1 ]]; then
    echo "Guess the secret number between 1 and 1000:"
    read USER_GUESS
    if [[ $USER_GUESS =~ ^[0-9]+$ ]];
    then
    USER_GUESS=$USER_GUESS
    else
echo "That is not an integer, guess again:"
    USER_GUESS=1001
    fi

  else
    USER_GUESS=$1
  fi

  while [[ $RANDOM_NUMBER -ne $USER_GUESS ]]; do
    ((NUMBER_OF_GUESSES++))
    
    if [[ $USER_GUESS -lt $RANDOM_NUMBER ]]; then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
    
    read USER_GUESS

    if [[ $USER_GUESS =~ ^[0-9]+$ ]];
    then
    USER_GUESS=$USER_GUESS
    else
echo "That is not an integer, guess again:"
    USER_GUESS=1001
    fi
  done

  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $USER_GUESS. Nice job!"
  #update games played
  #if not already games_played in db
  RETURN_GAMES_PLAYED=$($PSQL "select games_played from user_stats where username = '$USER_INPUT'")
  if [[ -z $RETURN_GAMES_PLAYED ]]
  then
  GAMES_PLAYED=$($PSQL "update user_stats SET games_played = '1' where username = '$USER_INPUT'")
  else
  GAMES_PLAYED=$($PSQL "UPDATE user_stats SET games_played = games_played + 1 where username = '$USER_INPUT'")
  fi
  
  #update best games
   #if not already best_played in db

  BEST_GAMES=$($PSQL "select best_games from user_stats where username = '$USER_INPUT'")
if [[ -z $BEST_GAMES ]]
then
NEW_BEST_GAME=$($PSQL "UPDATE user_stats SET best_games = '$NUMBER_OF_GUESSES' where username = '$USER_INPUT'")
else
if [[ $NUMBER_OF_GUESSES -lt $BEST_GAMES ]]
then
NEW_BEST_GAME=$($PSQL "UPDATE user_stats SET best_games = '$NUMBER_OF_GUESSES' where username = '$USER_INPUT'")
fi
fi
}

if [[ -z $USER_INPUT ]]
then
echo -e "No Valid entry"
else
USER_DATA=$($PSQL "\d")
USER_DATA=$($PSQL "select * from user_stats where username = '$USER_INPUT'")
IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAMES <<< "$USER_DATA"
if [[ -z $USERNAME ]]

then
ADD_USER_ID=$($PSQL "INSERT INTO user_stats(username) values('$USER_INPUT')")
echo "Welcome, $USER_INPUT! It looks like this is your first time here."
else
echo "Welcome back, $USER_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAMES guesses."
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
fi
NUMBER_GUESSING
fi




