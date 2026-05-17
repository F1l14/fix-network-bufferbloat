#!/bin/bash
# Add this near the top of your script to find the Hotspot interface name
HOTSPOT_IF=$(ip -o link show | awk -F': ' '/master/ {print $2}' | grep -v "wlo1" | head -n 1)

# If a hotspot is active, apply CAKE to it as well
if [ -n "$HOTSPOT_IF" ]; then
    sudo tc qdisc del dev $HOTSPOT_IF root 2> /dev/null
    sudo tc qdisc add dev $HOTSPOT_IF root cake bandwidth 85mbit triple-isolate wash ethernet
fi

# 1. Reset current state
tc qdisc del dev wlo1 root 2> /dev/null
tc qdisc del dev wlo1 ingress 2> /dev/null
tc qdisc del dev ifb0 root 2> /dev/null

# 2. Kernel Modules
modprobe ifb numifbs=1
ip link set dev ifb0 up

# 3. Hardware Optimization (Crucial for slow Upload/Wi-Fi)
ethtool -K wlo1 gso off gro off tso off
ip link set dev wlo1 txqueuelen 100

# 4. Upload Shaper 
# Caps at 8.5mbit to protect the 10.3mbps line. 
# 'rtt 30ms' helps it react faster to small Greek server pings.
tc qdisc add dev wlo1 root cake bandwidth 9mbit triple-isolate wash rtt 30ms ethernet

# 5. Ingress Redirect (Download)
tc qdisc add dev wlo1 handle ffff: ingress
tc filter add dev wlo1 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0

# 6. Download Shaper
# Caps at 75mbit to ensure the 'A+' result we saw.
tc qdisc add dev ifb0 root cake bandwidth 95mbit triple-isolate wash ingress ethernet rtt 30ms
