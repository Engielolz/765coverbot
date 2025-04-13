## Notice

765coverbot is no longer operating or supported as of April 2025. For information on the latest version of bash-atproto, please see the [bash-atproto repository](https://tangled.sh/@did:plc:s2cyuhd7je7eegffpnurnpud/bash-atproto).

# 765 Cover Bot

This is a bot thing made entirely in Bash and cURL that posts random covers by 765 Production idols.

For best results, run this behind a router without direct internet access. If an attacker manages to break into your server, they'll be able to use the saved credentials of the atproto accounts.

## bash-atproto

This is a bash script that makes calls to cURL which in turns makes calls to atproto APIs to authenticate and post.

It supports the following operations (most API calls are done to the account's PDS):

* Resolving a handle to did:plc/did:web

* Resolving an account's PDS from the DID

* Authenticating with the PDS

* Saving and loading a secrets file (contains your access and refresh tokens)

* Extracting account and token information from the access token

* Refreshing tokens

* Creating a text post (in any language)

* Reposting

* Preparing an image for Bluesky (including resizing and compressing)

* Uploading blobs

* Creating a post with a single embedded image with alt text

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

## License

765coverbot is licensed under the MIT License.
