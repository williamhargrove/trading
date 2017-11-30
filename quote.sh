#!/bin/bash

SYMBOL=$1
if [[ -z $SYMBOL ]]; then
echo "Please enter a SYMBOL as the first parameter to this script"
exit
fi

echo "Downloading quotes for $SYMBOL"

function log () {
# To remove logging comment echo statement and uncoment the :
  echo $1
# :
}

# Period values are 'Seconds since 1970-01-01 00:00:00 UTC'. Also known as Unix time or epoch time.
# Let's just assume we want it all and ask for a date range that starts at 1/1/1970.
  START_DATE=1483228800 # GMT: Sunday, January 1, 2017 12:00:00 AM
END_DATE=$(date +%s)

# Store the cookie in a temp file
cookieJar=$(mktemp)

# Get the crumb value
  function getCrumb () {
# Sometimes the value has an octal character
# echo will convert it
# https://stackoverflow.com/a/28328480
# curl the url then replace the } characters with line feeds. This takes the large json one line and turns it into about 3000 lines
# grep for the CrumbStore line
# then copy out the value
# lastly, remove any quotes
  echo -en "$(curl -s --cookie-jar $cookieJar $1)" | tr "}" "\n" | grep CrumbStore | cut -d':' -f 3 | sed 's+"++g'
  }

# TODO If crumb is blank then we probably don't have a valid symbol
URL="https://finance.yahoo.com/quote/$SYMBOL/?p=$SYMBOL"
  log $URL
crumb=$(getCrumb $URL)
#log $crumb
  log "CRUMB: $crumb"
  if [[ -z $crumb ]]; then
  echo "Error finding a valid crumb value"
  exit
  fi

# Build url with SYMBOL, START_DATE, END_DATE
  BASE_URL="https://query1.finance.yahoo.com/v7/finance/download/$SYMBOL?period1=$START_DATE&period2=$END_DATE&interval=1d&events=history"
#log $BASE_URL
# Add the crumb value
  URL="$BASE_URL&crumb=$crumb"
  log "URL: $URL"
# Download to
  curl -s --cookie $cookieJar  $URL > $SYMBOL.csv
  echo "Data dowmloaded to $SYMBOL.csv"

# The following line is for Vim users - please don't delete it.
# vim: set filetype=shell expandtab tabstop=2 shiftwidth=2:
