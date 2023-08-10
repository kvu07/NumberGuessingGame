#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number
NUMBER=$(( $RANDOM % 1000 + 1 ))

# get username
echo -e "\nEnter your username:"
read NAME

USERNAME=$($PSQL "SELECT username FROM games WHERE username='$NAME' LIMIT 1")

if [[ -z $USERNAME ]]
then
  # welcome new user
  echo -e "\nWelcome, $NAME! It looks like this is your first time here."

  # ensure username is at most 22 characters
  while [[ ${#NAME} -gt 22 ]]
  do
    echo "Username can be at most 22 characters. Please enter new username:"
    read NAME
  done

  USERNAME=$NAME

else
  # get prior game info for returning user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE username='$USERNAME'")
  BEST_NUM_OF_GUESSES=$($PSQL "SELECT MIN(guesses) FROM games WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_NUM_OF_GUESSES guesses."
fi

# play game
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
NUM_GUESSES=1

until [[ $GUESS = $NUMBER ]]
do
  if [[ ! $GUESS =~  ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  fi

  # another guess
  read GUESS
  ((NUM_GUESSES++))
done

# insert game into database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(username, guesses) VALUES('$USERNAME', $NUM_GUESSES)")

# output result
echo -e "\nYou guessed it in $NUM_GUESSES tries. The secret number was $NUMBER. Nice job!\n"
