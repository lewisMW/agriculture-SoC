#!/bin/bash

if (grep -r "Overlay Loaded" ./screenlog)
then
  echo "Bit file loaded successfully"
else
  echo "Bit file load failed"
  exit 1
fi
