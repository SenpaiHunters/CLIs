#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "\033[0;31mjq could not be found. Attempting to install...\033[0m"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        echo -e "\033[0;31mCould not determine OS type. Please install jq manually.\033[0m"
        exit 1
    fi
fi

# Function to fetch a question from the API
fetch_question() {
    local type=$1
    local rating=$2
    local response=$(curl -s "https://api.truthordarebot.xyz/v1/${type}?rating=${rating}")
    echo $response | jq -r '.question'
}

# Functions for each game
truth_or_dare() {
    while true; do
        echo -e "\033[0;32mEnter 'truth', 'dare', 'random' or 'back' to go back:\033[0m"
        read -p "" type
        type=$(echo "$type" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
        if [[ $type == "back" ]]; then
            break
        elif [[ $type == "random" ]]; then
            # Randomly select either "truth" or "dare"
            if (( RANDOM % 2 )); then
                type="truth"
            else
                type="dare"
            fi
            echo -e "\033[0;34mChosen type: $type\033[0m"
        elif [[ $type != "truth" && $type != "dare" ]]; then
            echo -e "\033[0;31mInvalid input. Please enter 'truth', 'dare', 'random' or 'back'.\033[0m"
            continue
        fi
        local rating="PG"
        local question=$(fetch_question $type $rating)
        echo -e "\033[0;34m$question\033[0m"
    done
}

would_you_rather() {
    while true; do
        echo -e "\033[0;32mEnter 'play' to get a question or 'back' to go back:\033[0m"
        read -p "" command
        command=$(echo "$command" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
        if [[ $command == "back" ]]; then
            break
        elif [[ $command == "play" ]]; then
            local rating="PG"
            local question=$(fetch_question "WYR" $rating)
            echo -e "\033[0;34m$question\033[0m"
        else
                echo -e "\033[0;31mInvalid input. Please enter 'play' or 'back'.\033[0m"
        fi
    done
}

never_have_I_ever() {
    while true; do
        echo -e "\033[0;32mEnter 'play' to get a question or 'back' to go back:\033[0m"
        read -p "" command
        command=$(echo "$command" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
        if [[ $command == "back" ]]; then
            break
        elif [[ $command == "play" ]]; then
            local rating="PG"
            local question=$(fetch_question "NHIE" $rating)
            echo -e "\033[0;34m$question\033[0m"
        else
            echo -e "\033[0;31mInvalid input. Please enter 'play' or 'back'.\033[0m"
        fi
    done
}

most_likely_to() {
    while true; do
        echo -e "\033[0;32mEnter 'play' to get a question or 'back' to go back:\033[0m"
        read -p "" command
        command=$(echo "$command" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
        if [[ $command == "back" ]]; then
            break
        elif [[ $command == "play" ]]; then
            local rating="PG"
            local question=$(fetch_question "PARANOIA" $rating)
            echo -e "\033[0;34m$question\033[0m"
        else
            echo -e "\033[0;31mInvalid input. Please enter 'play' or 'back'.\033[0m"
        fi
    done
}

# Ask the user for the type of game
while true; do
    echo -e "\033[0;32mAvailable games: 'truth or dare', 'would you rather', 'never have I ever', 'most likely to'\033[0m"
    read -p "Enter the name of the game you want to play or 'kill' to exit: " game
    game=$(echo "$game" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
    if [[ $game == "kill" ]]; then
        echo "Exiting the game."
        break
    elif [[ $game == "truth or dare" ]]; then
        truth_or_dare
    elif [[ $game == "would you rather" ]]; then
        would_you_rather
    elif [[ $game == "never have I ever" ]]; then
        never_have_I_ever
    elif [[ $game == "most likely to" ]]; then
        most_likely_to
    else
        echo -e "\033[0;31mInvalid input. Please enter the name of the game you want to play or 'kill'.\033[0m"
    fi
done
