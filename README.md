# fix-network-bufferbloat
A script to implement the CAKE smart queue management algorithm on linux to solve network bufferbloat.

It currently applies to wlo1, find your network interface with `ip link show
` and change it on the script file accordingly. The download & upload cap is set for 100Mb/s down 10Mbit/s up connection, feel free to change the settings for you connection.

## Script
  1. Resets any existing traffic trontrol in queue.
  2. Disable hardware offload to let the kernel manage the network packets, not the wifi card
  3. Caps upload traffic
  4. create a virtual network card to redirect and cap the download traffic
  5. Optimize regional latency from 100ms to 30ms
  6. Triple isolate feature to ensure faireness

  1. Move the script to `/usr/local/bin`
  2. `chmod +x fix-bufferbloat.sh`
  
## Service
  Starts the script on boot as an oneshot service after the network card initializes.
  1. copy the content of network-service.txt to `sudo nano /etc/systemd/system/network-optimization.service`
  2. `sudo systemctl daemon-reload`
  3.  `sudo systemctl daemon-reload`

  If you change the script's path change the path on the service too.

  ## TODO
  1. ~~To be able to un-apply the settings~~
  2. Fix the hotspot part
