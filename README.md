# SafeNode for Docker
[![](https://images.microbadger.com/badges/version/safecoin/safenode.svg)](https://hub.docker.com/r/safecoin/safenode)

Docker image that runs SafeNode in a container for easy deployment.

## Installation
### Requirements
#### [Install Docker](https://docs.docker.com/get-docker/)

### Fast setup
**If you are on ARM you have to use manual setup with `safecoin/safenode:arm-beta` as image.**

Run as root:
```
curl https://raw.githubusercontent.com/Fair-Exchange/safenode-docker/master/boostrap-host.sh | sh
```
###### root is needed for swap creation and systemd service. If you have enough memory and the user has the permission to run a docker container, you can run it as normal user.

### Manual setup
**Before to start the container, be sure to have at least 3GB free (RAM+SWAP)**

Run:
```
docker volume create --name safenode-data
docker run --restart always -p 8770:8770 -v safenode-data:/safenode --name=safenode -d safecoin/safenode
```

## Configure the container

#### 1. Create a SafeNode Paper Wallet
Go to https://safenodes.org/generate-wallet and create your SafeNode Paper Wallet.

#### 2. Run configuration script
Get your container id with `docker ps`, then run
```
docker exec -it safenode setup-safenode.sh
```

It will ask your SafeKey generated at point [#1](#1-Create-a-SafeNode-Paper-Wallet) and the actual blockchain height (optional)

If configuration ends fine you should read `SafeNode has been configured. Restart the container.`

#### 3. Restart the container
```
docker restart safenode
```

#### 4. Test that everything's fine
Wait about a minute from the start of the container and run
```
docker exec safecoin safecoin-cli getnodeinfo
```
It should behave like a normal safecoin-cli, printing informations about your node. After a while your node should appear [here](https://safenodes.org/). This will be the final confirmation that everything is working fine.

#### 5. Enable node
Get the wallet address with
```
docker exec safenode safecoin-cli listreceivedbyaddress 0 true
```
and send 1 SAFE to the that address, then send at least 10000 SAFE to the collateral address generated at [#1](#1-Create-a-SafeNode-Paper-Wallet).

**Now the node is enabled, you can double-check at https://safenodes.org/**

---
#### Use safecoin-cli
```
docker exec safenode safecoin-cli <args>
```

#### Create a wallet backup
```
docker cp safenode:/safenode/.safecoin/wallet.dat .
```

#### Gracefully shutdown the container
If you stop the container with `docker stop`, safecoind will have 10s to terminate before to be brutally killed (SIGKILL). It's not a good way to stop a container. You should instead do:
```
docker kill --signal=SIGTERM safecoind
docker stop safecoind
```

#### Keep the container up-to-date with systemd service
:warning: THIS IS AN EXPERIMENTAL FEATURE, BE SURE TO HAVE A BACKUP OF YOUR WALLETS AND THE WILL TO FIGHT AGAINST BUGS

You can enable a systemd service that will pull the latest image from our repositories at every boot copying `docker-safecoin.service` on systemd services' folder.
```
mv docker-safenode.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now docker-safenode.service
```

## FAQ
#### I want to run multiple SafeNode on my Docker
You can, but you will have to create containers following the [manual setup](#Manual-setup) and **creating a volume for each node**. For example you can run a second node with:
```
docker volume create --name safenode2-data
docker run -v safenode2-data:/safenode --name=safenode2 -d safecoin/safenode
```
Note how `safenode-data` is now `safenode2-data` in both commands; the container name has been changed so you can easily identify the right container id and port forwarding (`-p 8770:8770`) has been removed to avoid conflicts.

##### Be sure to have enough ram for all your containers!
#### Something's going wrong, how can I see logs?
```
docker logs safenode
```
You can use `--follow` argument to continue streaming the new output from the container’s STDOUT and STDERR.

#### I sadly need to debug. How can I spawn a shell into the container?
```
docker exec -it safenode bash
```
You will be on a Ubuntu image.

#### I have a problem or I can't find my question on FAQs
Join on [Discord](https://discord.gg/c6hWAkQ) and ask there. Someone will help you for sure! :)
