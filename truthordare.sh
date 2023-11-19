#!/bin/bash

# Default rating
rating="PG"

# Start timer
start_time=$(date +%s)

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "\n\033[0;31mjq could not be found. Attempting to install...\033[0m\n"
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
            local question=$(fetch_question $type)
        echo -e "\033[0;34m$question\033[0m"
        echo -e "----------------------------------------"  # Add separator
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
               local question=$(fetch_question "WYR")
        echo -e "\033[0;34m$question\033[0m"
        echo -e "----------------------------------------"  # Add separator
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
                local question=$(fetch_question "NHIE")
        echo -e "\033[0;34m$question\033[0m"
        echo -e "----------------------------------------"  # Add separator
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
                       local question=$(fetch_question "PARANOIA")
                echo -e "\033[0;34m$question\033[0m"
        echo -e "----------------------------------------"  # Add separator
        else
            echo -e "\033[0;31mInvalid input. Please enter 'play' or 'back'.\033[0m"
        fi
    done
}

# Settings function
settings() {
    echo -e "\n\033[0;32mEnter the default rating for all games (PG, -G13, R):\033[0m"
    read -p "" new_rating
    new_rating=$(echo "$new_rating" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
    if [[ $new_rating == "pg" || $new_rating == "-g13" || $new_rating == "r" ]]; then
        rating=$new_rating
        echo -e "\n\033[0;34mDefault rating set to: $rating\033[0m\n"
    else
        echo -e "\033[0;31mInvalid input. Please enter 'PG', '-G13', or 'R'.\033[0m"
    fi
}

# Ask the user for the type of game
while true; do
    echo -e "\n\033[0;32mAvailable games: 'truth or dare', 'would you rather', 'never have I ever', 'most likely to'\033[0m"
    echo -e "\033[0;32mEnter 'settings' to change the default rating for all games.\033[0m"
    read -p "Enter the name of the game you want to play, 'settings' to change the default rating, or 'kill' to exit: " game
    game=$(echo "$game" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
    if [[ $game == "kill" ]]; then
        end_time=$(date +%s)
        total_time=$((end_time - start_time))
        echo -e "\nTotal time playing: $total_time seconds\n"
        echo "Exiting the game."
        break
    elif [[ $game == "truth or dare" ]]; then
        truth_or_dare
    elif [[ $game == "would you rather" ]]; then
        would_you_rather
    elif [[ $game == "never have i ever" || $game == "never have i ever " ]]; then
    never_have_I_ever
    elif [[ $game == "most likely to" ]]; then
        most_likely_to
    elif [[ $game == "settings" ]]; then
        settings
    else
        echo -e "\n\033[0;31mInvalid input. Please enter the name of the game you want to play, 'settings' to change the default rating, or 'kill'.\033[0m"
    fi
done
