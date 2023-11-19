#!/bin/bash

API_KEY_FILE="$HOME/.weather_api_key"
API_KEY=""
LOCATION=""
LATITUDE=""
LONGITUDE=""
VERBOSE=0

# Read API key from file, if it exists
if [ -f "$API_KEY_FILE" ]; then
  API_KEY=$(cat "$API_KEY_FILE")
fi

# Function to display help message
display_help() {
    echo "Usage: $(basename "$0") [OPTIONS] <location>"
    echo "Fetch weather data for a specific location."
    echo
    echo "Options:"
    echo "  --api-key KEY       Set the API key to KEY."
    echo "  --api-remove        Remove the stored API key."
    echo "  --help              Display this help message."
    echo "  --verbose           Display more information about what the script is doing."
    echo
    echo "Location can be a city name, a city name and country code separated by a comma,"
    echo "or a latitude and longitude separated by a space."
}

# Parse command-line arguments
while (( "$#" )); do
  case "$1" in
    --api-key)
      API_KEY=$2
      echo "$API_KEY" > "$API_KEY_FILE"  # Save API key to file
      [ $VERBOSE -eq 1 ] && echo "API key set to $API_KEY"
      shift 2
      ;;
    --api-remove)
      rm "$API_KEY_FILE"  # Remove API key file
      [ $VERBOSE -eq 1 ] && echo "API key removed."
      exit 0
      ;;
    --unit)
      UNIT=$2
      [ $VERBOSE -eq 1 ] && echo "Unit set to $UNIT"
      shift 2
      ;;
    --help)
      display_help
      exit 0
      ;;
    --verbose)
      VERBOSE=1
      echo "Verbose mode enabled."
      shift
      ;;
    *)
      if [[ -z "$LOCATION" ]]; then
        LOCATION=$1
        [ $VERBOSE -eq 1 ] && echo "Location set to $LOCATION"
      elif [[ -z "$LATITUDE" ]]; then
        LATITUDE=$1
        [ $VERBOSE -eq 1 ] && echo "Latitude set to $LATITUDE"
      else
        LONGITUDE=$1
        [ $VERBOSE -eq 1 ] && echo "Longitude set to $LONGITUDE"
      fi
      shift
      ;;
  esac
done

if [ -z "$API_KEY" ]; then
    printf "No API key provided. Please get your API key from http://api.openweathermap.org and use it with --api-key option.\n"
    exit 1
fi

if [ -z "$LOCATION" ] && [ -z "$LATITUDE" ] && [ -z "$LONGITUDE" ]; then
    printf "Usage:\n"
    printf "  %s --api-key <api_key> <city>\n" "$(basename "$0")"
    printf "  %s --api-key <api_key> <city,country>\n" "$(basename "$0")"
    printf "  %s --api-key <api_key> <latitude> <longitude>\n" "$(basename "$0")"
    printf "Please provide a location or longitude and latitude as arguments.\n"
    exit 1
fi

# Check if latitude and longitude are provided
if [ -n "$LATITUDE" ] && [ -n "$LONGITUDE" ]; then
    location="lat=$LATITUDE&lon=$LONGITUDE"
else
    # Replace comma and space with plus sign for city and country names
    location="q=${LOCATION//[, ]/+}"
fi

#  Where the meat happens
response=$(curl -s "http://api.openweathermap.org/data/2.5/weather?$location&appid=$API_KEY" | jq -r '.' 2>> error.log)
weather=$(echo $response | jq -r '.weather[0]')
main=$(echo $response | jq -r '.main')
wind=$(echo $response | jq -r '.wind')

city=$(echo $response | jq -r '.name')
weather_description=$(echo $weather | jq -r '.description')
temperature_kelvin=$(echo $main | jq -r '.temp')
humidity=$(echo $main | jq -r '.humidity')
wind_speed=$(echo $wind | jq -r '.speed')
pressure=$(echo $main | jq -r '.pressure')
visibility_meters=$(echo $response | jq -r '.visibility')
cloudiness=$(echo $response | jq -r '.clouds.all')
rain_1h=$(echo $response | jq -r '.rain."1h" // 0')  # Set to 0 if null
snow_1h=$(echo $response | jq -r '.snow."1h" // 0')  # Set to 0 if null
timezone=$(echo $response | jq -r '.timezone // 0')  # Set to 0 if null
country=$(echo $response | jq -r '.sys.country')


temperature_celsius=$(printf "%.2f" $(echo "$temperature_kelvin - 273.15" | bc))

# Fetch additional data from the API
feels_like_temperature_kelvin=$(echo $main | jq -r '.feels_like')
feels_like_temperature=$(printf "%.2f" $(echo "$feels_like_temperature_kelvin - 273.15" | bc))
min_temperature_kelvin=$(echo $main | jq -r '.temp_min')
min_temperature=$(printf "%.2f" $(echo "$min_temperature_kelvin - 273.15" | bc))
max_temperature_kelvin=$(echo $main | jq -r '.temp_max')
max_temperature=$(printf "%.2f" $(echo "$max_temperature_kelvin - 273.15" | bc))
wind_direction_deg=$(echo $wind | jq -r '.deg')
sunrise_timestamp=$(echo $response | jq -r '.sys.sunrise')
sunset_timestamp=$(echo $response | jq -r '.sys.sunset')

# Convert Unix timestamp to human-readable time
sunrise=$(date -u -r $sunrise_timestamp  +%H:%M)
sunset=$(date -u -r $sunset_timestamp  +%H:%M)

# Convert wind direction in degrees to cardinal direction
cardinal_directions=("N" "NNE" "NE" "ENE" "E" "ESE" "SE" "SSE" "S" "SSW" "SW" "WSW" "W" "WNW" "NW" "NNW")
wind_direction=${cardinal_directions[$((($wind_direction_deg % 360) / 22))]}

# Check if visibility is not limited
if [[ "$visibility_meters" != "null" && "$visibility_meters" -ge 10000 ]]; then
    visibility="Clear day"
else
    visibility="${visibility_meters} m"
fi


printf "\nWeather in %s, %s\n" "$city" "$country"
printf "====================\n"
printf "Description: %s\n" "$weather_description"
printf "Temperature: %s°C (Feels like %s°C)\n" "$temperature_celsius" "$feels_like_temperature"
printf "Min/Max Temperature: %s/%s°C\n" "$min_temperature" "$max_temperature"
printf "Pressure: %s hPa\n" "$pressure"
printf "Humidity: %s%%\n" "$humidity"
printf "Visibility: %s\n" "$visibility"
printf "Cloudiness: %s%%\n" "$cloudiness"
printf "Rain (1h): %s mm\n" "$rain_1h"
printf "Snow (1h): %s mm\n" "$snow_1h"
printf "Wind Speed: %sKm/h\n" "$wind_speed"
printf "Wind Direction: %s\n" "$wind_direction"
printf "Sunrise: %s\n" "$sunrise"
printf "Sunset: %s\n" "$sunset"
printf "Timezone: UTC %s\n" "$timezone"

read -p "Would you like to hear an inspirational quote? (Y/N) " answer
if [[ $answer == "Y" || $answer == "y" ]]; then
    quote=$(curl -s https://api.quotable.io/random | jq -r '.content, .author' | paste -sd ' - ' - 2>> error.log)
    printf "\nHere is your quote:\n%s\n" "$quote"
fi
