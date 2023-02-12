#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ANSWER=$(( $RANDOM % 1000 + 1 ))
echo $ANSWER

echo -e "Enter your username:"
read USERNAME

USER_ID=$($PSQL "select user_id from users where user_name='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "insert into users(user_name) values('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where user_name='$USERNAME'")
  TOTAL_GAMES=0
  BEST_GAME=10000
else
  TOTAL_GAMES=$($PSQL "select total_games from users where user_id=$USER_ID")
  BEST_GAME=$($PSQL "select best_game from users where user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $(echo $TOTAL_GAMES | sed -E 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -E 's/^ *| *$//g') guesses."
fi

GUESS_COUNT=1
GUESS=10000

while [[ $GUESS != $ANSWER ]]
do
  if [[ $GUESS_COUNT == 1 ]]
  then
    echo -e "Guess the secret number between 1 and 1000:"
  fi
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS == $ANSWER ]]
    then
      echo -e "You guessed it in $(echo $GUESS_COUNT | sed -E 's/^ *| *$//g') tries. The secret number was $(echo $ANSWER | sed -E 's/^ *| *$//g'). Nice job!"
      GAME_UPDATE=$($PSQL "update users set total_games=$(( $TOTAL_GAMES + 1 )) where user_id=$USER_ID")
      if [[ $GUESS_COUNT -lt $BEST_GAME ]]
      then
        BEST_GAME_UPDATE=$($PSQL "update users set best_game=$GUESS_COUNT where user_id=$USER_ID")
      fi
      exit
    elif [[ $GUESS > $ANSWER ]]
    then
      echo -e "It's lower than that, guess again:"
    else
      echo -e "It's higher than that, guess again:"
    fi
  else
    echo -e "That is not an integer, guess again:"
  fi
  GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
done
