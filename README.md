# bash-atproto

Perhaps the cheapest and dirtiest way to make a bot for Bluesky, this is a bash script that makes calls to cURL which in turns makes calls to Bluesky APIs to authenticate and post.

This script will eventually handle the 765 Production Cover Bot.

**Do not use this for anything serious!**

If for whatever reason you still want to use this, remember that this script will break in the far future when OAuth is required to authenticate with ATProto.

## Setup

This is intended to be ran on an always-on system behind a router; basically, this would be perfect to throw on the same computer you use for pihole or something else that is meant for local networks and thus isn't affected by hackers.

1. Edit the service file to your needs

2. Copy service to /etc/systemd/system

3. Move/copy the script file to where the service wants it

4. Run the script with your Bluesky handle and app password to get the API token

5. Install service with `sudo systemctl enable 765cover && sudo systemctl start 765cover`
