#!/bin/bash
# TCPdump Interactive Wrapper Tool with ASCII Art and Colorized Output Option
# This tool builds and executes tcpdump commands interactively.
# It displays ASCII art with lolcat and optionally colorizes tcpdump's output using ccze.
#
# Requirements:
#   - lolcat (for the ASCII art)
#   - ccze (for colorizing tcpdump output)
#
# Install them using your package manager (e.g., apt-get install lolcat ccze)

# Display ASCII art with lolcat styling
cat << "EOF" | lolcat

                                                                           dddddddd
         tttt                                                              d::::::d
      ttt:::t                                                              d::::::d
      t:::::t                                                              d::::::d
      t:::::t                                                              d:::::d
ttttttt:::::ttttttt        ccccccccccccccccppppp   ppppppppp       ddddddddd:::::d uuuuuu    uuuuuu     mmmmmmm    mmmmmmm   ppppp   ppppppppp
t:::::::::::::::::t      cc:::::::::::::::cp::::ppp:::::::::p    dd::::::::::::::d u::::u    u::::u   mm:::::::m  m:::::::mm p::::ppp:::::::::p
t:::::::::::::::::t     c:::::::::::::::::cp:::::::::::::::::p  d::::::::::::::::d u::::u    u::::u  m::::::::::mm::::::::::mp:::::::::::::::::p
tttttt:::::::tttttt    c:::::::cccccc:::::cpp::::::ppppp::::::pd:::::::ddddd:::::d u::::u    u::::u  m::::::::::::::::::::::mpp::::::ppppp::::::p
      t:::::t          c::::::c     ccccccc p:::::p     p:::::pd::::::d    d:::::d u::::u    u::::u  m:::::mmm::::::mmm:::::m p:::::p     p:::::p
      t:::::t          c:::::c              p:::::p     p:::::pd:::::d     d:::::d u::::u    u::::u  m::::m   m::::m   m::::m p:::::p     p:::::p
      t:::::t          c:::::c              p:::::p     p:::::pd:::::d     d:::::d u::::u    u::::u  m::::m   m::::m   m::::m p:::::p     p:::::p
      t:::::t    ttttttc::::::c     ccccccc p:::::p    p::::::pd:::::d     d:::::d u:::::uuuu:::::u  m::::m   m::::m   m::::m p:::::p    p::::::p
      t::::::tttt:::::tc:::::::cccccc:::::c p:::::ppppp:::::::pd::::::ddddd::::::ddu:::::::::::::::uum::::m   m::::m   m::::m p:::::ppppp:::::::p
      tt::::::::::::::t c:::::::::::::::::c p::::::::::::::::p  d:::::::::::::::::d u:::::::::::::::um::::m   m::::m   m::::m p::::::::::::::::p
        tt:::::::::::tt  cc:::::::::::::::c p::::::::::::::pp    d:::::::::ddd::::d  uu::::::::uu:::um::::m   m::::m   m::::m p::::::::::::::pp
          ttttttttttt      cccccccccccccccc p::::::pppppppp       ddddddddd   ddddd    uuuuuuuu  uuuummmmmm   mmmmmm   mmmmmm p::::::pppppppp
                                            p:::::p                                                                           p:::::p
                                            p:::::p                                                                           p:::::p
                                           p:::::::p                                                                         p:::::::p
                                           p:::::::p                                                                         p:::::::p
                                           p:::::::p                                                                         p:::::::p
                                           ppppppppp                                                                         ppppppppp

EOF

echo ""
echo "=========================================="
echo "    TCPdump Interactive Wrapper Tool      "
echo "=========================================="
echo ""

# Main interactive menu
echo "Select monitoring mode:"
echo "  1) Internal Network Monitoring"
echo "  2) External Network Monitoring"
read -p "Enter selection (1 or 2): " mode

if [[ "$mode" == "1" ]]; then
    echo ""
    echo "=== Internal Network Monitoring ==="
    filter=""

    # Option 1: Monitor Specific Subnet
    read -p "Monitor a specific subnet? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter subnet (e.g., 192.168.1.0/24): " subnet
        filter+=" net $subnet"
    fi

    # Option 2: Filter by Source or Destination Host
    read -p "Filter by a specific host? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter host IP: " host_ip
        if [[ -n "$filter" ]]; then
            filter+=" and host $host_ip"
        else
            filter+=" host $host_ip"
        fi
    fi

    # Option 3: Capture Specific Port Traffic
    read -p "Capture specific port traffic? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter port number (e.g., 22 for SSH): " port
        if [[ -n "$filter" ]]; then
            filter+=" and port $port"
        else
            filter+=" port $port"
        fi
    fi

    # Option 4: Exclude Specific Traffic
    read -p "Exclude specific traffic? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter exclusion expression (e.g., port 80): " exclude_expr
        if [[ -n "$filter" ]]; then
            filter+=" and not ($exclude_expr)"
        else
            filter+=" not ($exclude_expr)"
        fi
    fi

    # Option 5: Verbose Output
    read -p "Enable verbose output? (y/n): " ans
    verbose=""
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        verbose="-v"
    fi

    # Interface and packet count options
    read -p "Enter interface to capture on (default: eth0): " iface
    iface=${iface:-eth0}
    read -p "Enter number of packets to capture (leave blank for unlimited): " count
    if [[ -n "$count" ]]; then
        count_opt="-c $count"
    else
        count_opt=""
    fi

    # Build the final tcpdump command
    cmd="tcpdump -i $iface $verbose $count_opt $filter"

elif [[ "$mode" == "2" ]]; then
    echo ""
    echo "=== External Network Monitoring ==="
    filter=""

    # Option 1: Capture Traffic on External Interface
    read -p "Enter external interface to capture on (default: eth0): " iface
    iface=${iface:-eth0}

    # Option 2: Filter Traffic by IP Address
    read -p "Filter by a specific external IP? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter external IP address: " ext_ip
        filter+=" host $ext_ip"
    fi

    # Option 3: Capture Traffic to Specific Port
    read -p "Capture traffic for a specific port? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter port number (e.g., 443 for HTTPS): " port
        if [[ -n "$filter" ]]; then
            filter+=" and port $port"
        else
            filter+=" port $port"
        fi
    fi

    # Option 4: Capture Only Outgoing Traffic
    read -p "Capture only outgoing traffic? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter source IP for outgoing traffic: " src_ip
        if [[ -n "$filter" ]]; then
            filter+=" and src host $src_ip"
        else
            filter+=" src host $src_ip"
        fi
    fi

    # Option 5: Capture Non-Local Traffic
    read -p "Capture non-local traffic (exclude local network)? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -p "Enter local network to exclude (e.g., 192.168.1.0/24): " local_net
        if [[ -n "$filter" ]]; then
            filter+=" and not net $local_net"
        else
            filter+=" not net $local_net"
        fi
    fi

    # Verbose output option
    read -p "Enable verbose output? (y/n): " ans
    verbose=""
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        verbose="-v"
    fi

    # Packet count option
    read -p "Enter number of packets to capture (leave blank for unlimited): " count
    if [[ -n "$count" ]]; then
        count_opt="-c $count"
    else
        count_opt=""
    fi

    # Build the final tcpdump command
    cmd="tcpdump -i $iface $verbose $count_opt $filter"

else
    echo "Invalid selection. Exiting."
    exit 1
fi

echo ""
echo "Built tcpdump command:"
echo "$cmd"
echo ""

# Ask if the user wants colorized real-time output
read -p "Enable colorized output for tcpdump (requires ccze)? (y/n): " color_ans
echo ""

# Execute the command with or without colorized output
if [[ "$color_ans" =~ ^[Yy]$ ]]; then
    echo "Executing: $cmd | ccze -A"
    eval "$cmd" | ccze -A
else
    echo "Executing: $cmd"
    eval "$cmd"
fi