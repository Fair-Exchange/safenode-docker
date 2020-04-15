#!/bin/bash

set -e

echo "# SafeNode configuration script #"
if [ -f $HOME/.safecoin/safecoin.conf ]; then
    echo "[!!!] You have already configured a SafeNode"
    echo "[!!!] If you continue, your SafeNode configuration"
    echo "[!!!] will be overwritten"
    read -p "Overwrite [y/N]: " overwrite
    [[ "$overwrite" == [yY] ]] || exit 1
fi

while :
do
    read -p "SafeKey: " safekey
    if [ ${#safekey} -eq 66 ]; then
        break
    fi
    echo "[!!!] Invalid SafeKey"
done

while :
do
    read -p "Blockchain height (if empty, will get from explorer's api): " blockheight
    if [ -z "$blockheight" ]; then
        blockheight=$(curl -s https://explorer.safecoin.org/api/blocks/\?limit=1 | grep -o '"height":[0-9]*' | cut -c10-)
        if [ -n "$blockheight" ]; then
            echo "Actual block: $blockheight"
            break
        fi
        echo "[!!!] Unable to fetch current block height from explorer. Please enter it manually. You can obtain it from https://explorer.safecoin.org or https://explorer.deepsky.space/"
    fi
    if [[ "$blockheight" =~ ^[0-9]+$ ]]; then
        break
    fi
done

if [ -n "$overwrite" ]; then
    echo "Backing up old configuration and wallet..."
    mv ~/.safecoin/wallet.dat ~/.safecoin/wallet$(date "+%Y.%m.%d-%H.%M.%S").dat.bkp 2> /dev/null
    mv ~/.safecoin/safecoin.conf ~/.safecoin/safecoin$(date "+%Y.%m.%d-%H.%M.%S").conf.bkp 2> /dev/null
fi

mkdir ~/.safecoin || true

read -p "Do you want to add nodes to speed up syncing? [Y/n]" addnodes
if [[ "$addnodes" =~ ^(Y|y)*$ ]]; then
    echo "addnode=explorer.safecoin.org
addnode=explorer.deepsky.space
addnode=dnsseed.local.support
addnode=dnsseed.fair.exchange
" > ~/.safecoin/safecoin.conf
fi

# Some of these index could not be needed
# someone should check if everything's fine
# without some/any of these
echo "txindex=1
timestampindex=1
addressindex=1
spentindex=1

safekey=$safekey
safepass=$(dd if=/dev/urandom bs=33 count=1 2>/dev/null | base64)
parentkey=0333b9796526ef8de88712a649d618689a1de1ed1adf9fb5ec415f31e560b1f9a3
safeheight=$blockheight" >> ~/.safecoin/safecoin.conf

echo
echo "SafeNode has been configured. Restart the container."