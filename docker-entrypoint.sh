#!/bin/sh

if [ ! -f $HOME/.safecoin/safecoin.conf ]; then
    echo "SafeNode hasn't been configured yet. Follow these steps: https://github.com/Fair-Exchange/safenode-docker/#Configure-the-container"
    trap "exit 1" TERM
    while :; do sleep 1; done
fi

echo "Checking fetch-params..."
fetch-params.sh > /dev/null
echo "Initialization completed successfully"
echo

echo "****************************************************"
echo "Running: safecoind $@"
echo "****************************************************"

exec safecoind $@