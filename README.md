# Home scripe
-----
Utilize Docker to create automation tasks for home media server. this is heavily inspired by [animosity22/homescripts](https://github.com/animosity22/homescripts/) (just everything in a docker), special thanks!


## Features

- remote media library with local mount/cache
  - [rclone](https://rclone.org/)
  - [mergerfs](https://github.com/trapexit/mergerfs)
- downloader 
  - [qbittorrent](https://hotio.dev/containers/qbittorrent/)
  - nzbget
  - transmission
- *arr (*choose whatever you need*)
  - sonarr
  - radarr
  - bazarr
  - lidarr
  - Readarr
- other plugin/helpers for *aar
  - Jackett: indexer
  - [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr): Bypass Cloudflare protection in Jackett *Optional*
- Other Utility
  - portainer: for docker management
  - ddclient
### To be added
- Proxy/VPN
  - Wireguard
- Cabby


## Environment
I personally am running all this setup on my mining rig with a super low end celeron process with 8GB of ram, running ubuntu bionic 64bit. 

## Installation

1. Install docker 
2. Install your graphic driver and their docker componments for hardware en/de-coding in jellyfin. check [Jellyfin support link](https://jellyfin.org/docs/general/administration/hardware-acceleration.html)
   1. Nvidia [Driver](https://phoenixnap.com/kb/install-nvidia-drivers-ubuntu) and [Docker](https://github.com/NVIDIA/nvidia-docker) support (this is what I'm using, anything else is not supported) [^1].
      
   2. AMD (No idea)
   3. Intel (Intel Quick Sync Video) (No idea)
3. I don't know yet. 


     
[^1]: I'm running on a disribution with pre-installed driver (MinerOS) instead of setting it up from scratch, mostly because that I couldn't find a good overclocking (downclocking) solution. But as far as I remember, there are some gotchas, for examples

* Multi-GPU support. 
  * This is more of an OS issue, which you can find more looking at the `dmesg` logs. The solution, as far as i remember, you need to firstly enable above 4g decoding in BIOS, then add something like pcie=preallocate (i can't find it anymore so good luck and if anyone knows, PR is welcomed)
* Nvidia docker cgroup issue. [see this](https://github.com/NVIDIA/nvidia-docker/issues/1447#issuecomment-757034464)



## Useful links


- [wiki.servarr](https://wiki.servarr.com/docker-guide) General guid on *aar, very useful
- [Setup Guide: Multi GPU Ubuntu Server AMD & nvidia](https://foldingforum.org/viewtopic.php?f=106&t=33090) (never tried myself, not looks promissing so have a read)
- [Ubuntu with multiple GPU for mining](https://gist.github.com/ernestp/83bfd1667b1f5c3905b5c15dc9031811) (I didn't actually see this until now, might give stock ubuntu another go. )