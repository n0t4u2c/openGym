# Deploying StuFit to the Synology

`compose.yaml` here is the one the NAS runs. `update.sh` is pasted once into a DSM Task
Scheduler task (user-defined script, run as root). Pressing Run on that task fetches this
compose file from GitHub, pulls the images, and restarts only what changed.

The tunnel token is never in the repo. It lives in `/volume1/docker/stufit/.env` on the NAS:

    TUNNEL_TOKEN=<token from Cloudflare>

To release: bump the two image tags in `compose.yaml`, push to `stufit`, press Run on the NAS.
