#!/bin/bash
TMPFILE=/tmp/$RANDOM
touch $TMPFILE
curl -s --data '{
    "jsonrpc": "2.0",
    "method": "generateIntegers",
    "params": {
        "apiKey": "0d9b79b3-e7fb-4d9e-9b8e-3e369dda67f8",
        "n": 2,
        "min": 10,
        "max": 99,
        "replacement": true
    },
    "id": 42
}' https://api.random.org/json-rpc/1/invoke > $TMPFILE

VAR1=`cat $TMPFILE | jq .result.random.data[0]`
VAR2=`cat $TMPFILE | jq .result.random.data[1]`
echo "$VAR1;$VAR2"
rm $TMPFILE

