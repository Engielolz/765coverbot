# 765 Cover Bot

This is a bot thing made entirely in Bash and cURL that posts random covers by 765 Production idols.

## bash-atproto

This is a bash script that makes calls to cURL which in turns makes calls to Bluesky APIs to authenticate and post.

It supports the following operations (most API calls are done to the account's PDS):

* Resolving a handle to did:plc

* Resolving an account's PDS from the DID

* Authenticating with your PDS

* Saving and loading a secrets file (contains your access and refresh tokens)

* Refreshing access tokens

* Creating a text post (in en-US)

* Reposting

* Preparing an image for Bluesky (including resizing and compressing)

* Uploading blobs

* Creating a post with a single embedded image with alt text

While that's all cool and all, **do not use this for anything serious!** This is tested to work for bots posting every hour, behind a router without direct internet access. If someone manages to break into your server, they'll be able to use the saved secrets and ruin your Bluesky accounts.

If for whatever reason you still want to use this, remember that this script will break in the future when OAuth is required to authenticate with ATProto.

In the context of 765coverbot, the functions related to reposting, blobs and images are not used. These functions however are used in [imasimgbot](https://github.com/engielolz/imasimgbot).

### Dependencies

To use this script you will need:

* `curl` 7.76.0 or later. 

* `jq`

Posting images (not used by 765coverbot) additionally requires `imagemagick`, `exiftool` and `uuidgen`, though the latter should come with your Linux distro.

## Setup

This is intended to be ran on an always-on system behind a router; basically, this would be perfect to throw on the same computer you use for pihole or something else that is meant to run on your local network and doesn't directly talk to the web.

You will probably need to run all these commands as root:

1. Go to `/usr/local/bin` and `git clone` this repository

2. Run the script with your Bluesky handle and app password to get the API token
   
   `./765cover.sh usernameOrDid appPassword`

3. Run `765cover.sh` with the parameter `--install` which will install and enable the bot service

4. Start the bot with `systemctl start 765coverbot`

To uninstall the bot, stop the bot with `systemctl stop 765coverbot` then run the script as root with the parameter `--uninstall` which will disable and remove the service file. Then you can remove the directory `/usr/local/bin/765coverbot` to fully remove the bot.
