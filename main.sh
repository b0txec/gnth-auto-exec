#!/bin/bash

# blank lines before the ASCII art
echo ""
echo ""

# ASCII art with lolcat
cat << "EOF" | sed 's/^/  /' | lolcat

    ___         __        ______              
   /   | __  __/ /_____  / ____/  _____  _____
  / /| |/ / / / __/ __ \/ __/ | |/_/ _ \/ ___/
 / ___ / /_/ / /_/ /_/ / /____>  </  __/ /__  
/_/  |_\__,_/\__/\____/_____/_/|_|\___/\___/  
                                              
EOF

# blank lines and the title message
echo ""
echo "         choose your tool" | lolcat -f
echo ""
echo ""
echo ""

# Define tools with descriptions
tool_names=("Gobuster" "Nmap" "TCP-Dump" "Hydra" "I Want To Leave")
tool_descriptions=(
    "- Directory and subdomain brute-forcing tool"
    "- Network scanner for port and service discovery"
    "- Packet capture and network traffic analysis"
    "- Fast password brute-forcing tool"
    "- Exit the script"
)

# Display menu with tool names in light green and descriptions in default color
for i in "${!tool_names[@]}"; do
    printf "%d) \e[1;32m%s\e[0m %s\n" "$((i+1))" "${tool_names[$i]}" "${tool_descriptions[$i]}"
done

echo ""

# Menu prompt
while true; do
    echo -n "Choose a tool to run: "
    read -r choice

    case $choice in
        1) ./g0.sh ;;
        2) ./nmap.sh ;;
        3) ./tcpdump.sh ;;
        4) ./hydra.sh ;;
        5) break ;;
        *) echo -e "\e[1;31mInvalid option, try again.\e[0m" ;;  # Red error message
    esac
done

# message after quitting
echo "real coders build stuff" | lolcat