# 765 Cover Bot

This is a bot thing made entirely in Bash and cURL that posts random covers by 765 Production idols.

## bash-atproto

Perhaps the cheapest and dirtiest way to make a bot for Bluesky, this is a bash script that makes calls to cURL which in turns makes calls to Bluesky APIs to authenticate and post.

**Do not use this for anything serious!**

If for whatever reason you still want to use this, remember that this script will break in the future when OAuth is required to authenticate with ATProto.

### Dependencies

To use this script you will need:

* cURL 7.76.0 or later. 

* jq

The other dependencies should come with your Linux distro.

## Setup

This is intended to be ran on an always-on system behind a router; basically, this would be perfect to throw on the same computer you use for pihole or something else that is meant to run on your local network and doesn't directly talk to the web.

You will probably need to run all these commands as root:

1. Go to `/usr/local/bin` and `git clone` this repository

2. Run the script with your Bluesky handle and app password to get the API token
   
   `./765cover.sh usernameOrDid appPassword`

3. Run `765cover.sh` with the parameter `--install` which will install and enable the bot service

4. Start the bot with `sudo systemctl start 765coverbot`

To uninstall the bot, stop the bot with `systemctl stop 765coverbot` then run the script as root with the parameter `--uninstall` which will disable and remove the service file. Then you can remove the directory `/usr/local/bin/765coverbot` to fully remove the bot.
