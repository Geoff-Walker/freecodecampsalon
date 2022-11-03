#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ Salon ~~~~~\n"
echo -e "A list of our services"
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
MAIN_MENU() {
  #error message
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi
#List services
 echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
 do 
 echo -e "$SERVICE_ID) $NAME"
 done
# Read the service
read SERVICE_ID_SELECTED

#If not a number restart
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
 MAIN_MENU "This is not a service number, please select a number listed"
fi
# IF not in list restart
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_NAME ]]
then
 MAIN_MENU "This is not a service we provide please choose again"
fi
# Enter Customer phone number
echo -e "\nPlease enter your Phone number format 555-555-5555"
read CUSTOMER_PHONE
#Get Customer specific variables
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")


if [[ -z $CUSTOMER_NAME ]]
then
echo -e "\nYou don't seem to be registered what is your name?"
read CUSTOMER_NAME
#add user
INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi
#Choose Time
echo -e "\nWhat time would you like your treatment?"
read SERVICE_TIME
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
#Add appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
 if [[ $INSERT_APPOINTMENT != "INSERT 0 1" ]]
  then
    MAIN_MENU "ERROR, something went wrong. Please try again."
  else
    echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
exit
}
MAIN_MENU