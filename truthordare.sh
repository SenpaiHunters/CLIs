#!/bin/bash

# Function to fetch a question from the API
fetch_question() {
    local type=$1
    local rating=$2
    local response=$(curl -s "https://api.truthordarebot.xyz/v1/${type}?rating=${rating}")
    echo $response | jq -r '.question'
}

# Ask the user for the type of question (truth, dare or random)
while true; do
    read -p "Enter 'truth', 'dare', 'random' or 'kill' to exit: " type
    type=$(echo "$type" | tr '[:upper:]' '[:lower:]')  # convert to lowercase
    if [[ $type == "kill" ]]; then
        echo "Exiting the game."
        break
    elif [[ $type == "random" ]]; then
        # Randomly select either "truth" or "dare"
        if (( RANDOM % 2 )); then
            type="truth"
        else
            type="dare"
        fi
        echo "Chosen type: $type"
    elif [[ $type != "truth" && $type != "dare" ]]; then
        echo "Invalid input. Please enter 'truth', 'dare', 'random' or 'kill'."
        continue
    fi
    rating="PG"
    question=$(fetch_question $type $rating)
    echo "$question"
done
