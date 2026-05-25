#!/bin/bash

echo "Starting network restoration to system defaults..."

# 1. Detect the hotspot/tether interface from the active master table
HOTSPOT_IF=$(ip -o link show | awk -F': ' '/master/ {print $2}' | grep -v "wlo1" | head -n 1)

# 2. Strip CAKE from the secondary/tether interface if present
if [ -n "$HOTSPOT_IF" ]; then
    echo "Removing traffic shaping from interface: $HOTSPOT_IF"
    sudo tc qdisc del dev "$HOTSPOT_IF" root 2> /dev/null
fi

# 3. Strip all queuing disciplines (qdiscs) and redirection filters from wlo1 and ifb0
echo "Removing CAKE and ingress redirect filters from wlo1 and ifb0..."
sudo tc qdisc del dev wlo1 root 2> /dev/null
sudo tc qdisc del dev wlo1 ingress 2> /dev/null
sudo tc qdisc del dev ifb0 root 2> /dev/null

# 4. Take down and unload the IFB kernel module
echo "Bringing down virtual interface ifb0 and unloading module..."
sudo ip link set dev ifb0 down 2> /dev/null
sudo modprobe -r ifb 2> /dev/null

# 5. Restore Hardware Offloading (Crucial to lower CPU overhead at standard speeds)
echo "Restoring hardware optimization offloads (GSO, GRO, TSO) on wlo1..."
sudo ethtool -K wlo1 gso on gro on tso on

# 6. Reset the Wi-Fi transmission queue length back to Linux desktop defaults
echo "Resetting wlo1 txqueuelen to standard fallback (1000)..."
sudo ip link set dev wlo1 txqueuelen 1000

# 7. Apply the standard Linux default qdisc (Fedora defaults to fq_codel)
echo "Re-applying default system queuing structure..."
sudo tc qdisc add dev wlo1 root fq_codel 2> /dev/null

echo "Network state successfully restored to system default!"
