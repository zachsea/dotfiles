#!/bin/bash

API_TOKEN=$(security find-generic-password -a "$USER" -s "sketchybar_glucose_key" -w)
API_URL="https://$(security find-generic-password -a "$USER" -s "sketchybar_glucose_domain" -w)/api/v1/entries/sgv?count=1&token=$API_TOKEN"

get_arrow() {
  case "$1" in
  "NONE") echo "⇼" ;;
  "DoubleUp") echo "⇈" ;;
  "SingleUp") echo "↑" ;;
  "FortyFiveUp") echo "↗" ;;
  "Flat") echo "→" ;;
  "FortyFiveDown") echo "↘" ;;
  "SingleDown") echo "↓" ;;
  "DoubleDown") echo "⇊" ;;
  "NOT COMPUTABLE") echo "-" ;;
  "RATE OUT OF RANGE") echo "⇕" ;;
  *) echo "?" ;;
  esac
}

GLUCOSE_DATA=$(curl -s -X GET "$API_URL" -H 'accept: application/json')

if [ $? -eq 0 ] && [ -n "$GLUCOSE_DATA" ]; then
  SGV=$(echo "$GLUCOSE_DATA" | jq -r '.[0].sgv // empty')
  DIRECTION=$(echo "$GLUCOSE_DATA" | jq -r '.[0].direction // empty')
  MILLS=$(echo "$GLUCOSE_DATA" | jq -r '.[0].mills // empty')

  if [ -n "$MILLS" ]; then
    NOW_MS=$(($(date +%s) * 1000))
    AGE_MS=$((NOW_MS - MILLS))
    FIFTEEN_MIN_MS=$((15 * 60 * 1000))

    if [ "$AGE_MS" -gt "$FIFTEEN_MIN_MS" ]; then
      sketchybar --set "$NAME" label="No recent data"
      exit 0
    fi
  else
    sketchybar --set "$NAME" label="No timestamp"
    exit 0
  fi

  if [ -n "$SGV" ] && [ -n "$DIRECTION" ]; then
    ARROW=$(get_arrow "$DIRECTION")
    sketchybar --set "$NAME" label="${SGV} mg/dL ${ARROW}"
  else
    sketchybar --set "$NAME" label="No data"
  fi

else
  sketchybar --set "$NAME" label="Error"
fi
