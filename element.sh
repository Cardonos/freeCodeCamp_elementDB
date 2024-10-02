#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align  -c"

ELEMENT=$1
NAME=""
SYMBOL=""

MAIN() {
  if [[ $ELEMENT ]]
  then
    #check whether number, symbol or name
    if [[ $ELEMENT =~ [0-9]+ ]]
    then
      ATOMIC_NUMBER=$ELEMENT
    elif [[ $ELEMENT =~ [A-Za-z] && ${#ELEMENT} < 3 ]]
    then
      ATOMIC_NUMBER=$($PSQL"SELECT atomic_number FROM elements WHERE symbol = '${ELEMENT}' ;")
      SYMBOL=$ELEMENT
    elif [[ $ELEMENT =~ [A-Za-z]+ ]]
    then
      ATOMIC_NUMBER=$($PSQL"SELECT atomic_number FROM elements WHERE name = '${ELEMENT}' ;")
      NAME=$ELEMENT
    fi
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo 'I could not find that element in the database.'
    else
      if [[ -z $NAME ]]
      then
        NAME=$($PSQL"SELECT name FROM elements WHERE atomic_number = ${ATOMIC_NUMBER};")
      fi
      if [[ -z $SYMBOL ]]
      then
        SYMBOL=$($PSQL"SELECT symbol FROM elements WHERE atomic_number = ${ATOMIC_NUMBER};")
      fi
    
      TYPE=$($PSQL"SELECT type FROM properties FULL JOIN types USING(type_id) FULL JOIN elements USING(atomic_number)  WHERE atomic_number = ${ATOMIC_NUMBER};")
      MASS=$($PSQL"SELECT atomic_mass FROM properties WHERE atomic_number = ${ATOMIC_NUMBER};")
      MELT=$($PSQL"SELECT melting_point_celsius FROM properties WHERE atomic_number = ${ATOMIC_NUMBER};")
      BOIL=$($PSQL"SELECT boiling_point_celsius FROM properties WHERE atomic_number = ${ATOMIC_NUMBER};")

      #return the data as echo
      echo  "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
      #if not found
      #return not findable
    fi
  else
    echo 'Please provide an element as an argument.'
  fi
}
MAIN
