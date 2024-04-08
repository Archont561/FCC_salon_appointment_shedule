#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
PSQL_QUERY() { ${PSQL} "$1"; }

# Function to display a numbered list of services and prompt for service selection
SELECT_SERVICE() {
    echo -e "\nWelcome to My Salon, how can I help you?\n"
    while true; do
        SERVICES=$(PSQL_QUERY "SELECT service_id, name FROM services;")
        while IFS='|' read -r SERVICE_ID SERVICE_NAME; do
            echo "$SERVICE_ID) $SERVICE_NAME"
        done <<< "$SERVICES"
        read SERVICE_ID_SELECTED
        SERVICE_NAME=$(PSQL_QUERY "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
        if [[ ! -z "$SERVICE_NAME" ]]; then 
            break 
        else
            echo -e "\nI could not find that service. What would you like today?"
        fi
    done
}

# Function to prompt user for phone number and check if customer exists
PROMPT_PHONE() {
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$(PSQL_QUERY "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    if [ -z "$CUSTOMER_NAME" ]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        PSQL_QUERY "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
    fi
    CUSTOMER_ID=$(PSQL_QUERY "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME';")
}

# Function to prompt user for time
PROMPT_TIME() {
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    PSQL_QUERY "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# main function to execute
MAIN() {
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    SELECT_SERVICE
    PROMPT_PHONE
    PROMPT_TIME
    echo "~~~~~ MY SALON ~~~~~"
}

MAIN
