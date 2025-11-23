#!/bin/bash

# Get the current split orientation (horizontal/vertical)
current=$(aerospace query --json containers | jq -r '
  .[] | select(.focused==true) | .split_direction
')

# Toggle it
if [ "$current" = "vertical" ]; then
  aerospace split horizontal
else
  aerospace split vertical
fi
