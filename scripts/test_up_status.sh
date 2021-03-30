#!/usr/bin/env bash

set -euo pipefail

test_server() {
    SERVER=$1

    sleep 2;
    retries=11
    echo "$SERVER"
    until curl -f $SERVER:5000/health
    do
      if (( retries-- == 0)) ;
        then docker rm $CONTAINER_NAME -f && exit 1;
        else printf "Server not up; Checking again in 5 seconds..\n" && sleep 5;
      fi
    done

}


