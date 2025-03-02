#!/bin/bash
# Nmap command wrapper
# Requirements: nmap and lolcat (for the title)

# check if nmap is installed.
if ! command -v nmap &> /dev/null; then
    echo "nmap is required but not installed. Please install nmap and try again."
    exit 1
fi

# check if lolcat is installed.
if ! command -v lolcat &> /dev/null; then
    echo "lolcat is required but not installed. Please install lolcat (e.g., sudo apt-get install lolcat) and try again."
    exit 1
fi

# define ANSI color codes.
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# clear the screen and display the title with lolcat.
clear

# blank lines before the ASCII art
echo ""
echo ""

cat << "EOF" | lolcat
 ███▄    █  ███▄ ▄███▓ ▄▄▄       ██▓███
 ██ ▀█   █ ▓██▒▀█▀ ██▒▒████▄    ▓██░  ██▒
▓██  ▀█ ██▒▓██    ▓██░▒██  ▀█▄  ▓██░ ██▓▒
▓██▒  ▐▌██▒▒██    ▒██ ░██▄▄▄▄██ ▒██▄█▓▒ ▒
▒██░   ▓██░▒██▒   ░██▒ ▓█   ▓██▒▒██▒ ░  ░
░ ▒░   ▒ ▒ ░ ▒░   ░  ░ ▒▒   ▓▒█░▒▓▒░ ░  ░
░ ░░   ░ ▒░░  ░      ░  ▒   ▒▒ ░░▒ ░
   ░   ░ ░ ░      ░     ░   ▒   ░░
         ░        ░         ░  ░
EOF

# welcome and instructions.
echo -e "\n${CYAN}Automatic commands for Nmap.${NC}"
echo "No need to manually compile commands."
echo "Follow the prompts to select your target, choose one or more scan options."
echo ""

# prompt for target details.
read -p "Enter target IP/hostname: " TARGET
read -p "Enter port(s) or port range (e.g., 80,22,1-1000) [Leave blank for default ports]: " PORTS

# initialize the scan options variable.
SCAN_OPTIONS=""

# function to display the colored menu.
show_menu() {
    echo -e "\n${CYAN}Select a scan option by typing the corresponding number:${NC}"
    echo -e "${YELLOW}1)${NC} ${GREEN}SYN Scan (-sS)           : A fast and stealthy scan.${NC}"
    echo -e "${YELLOW}2)${NC} ${GREEN}UDP Scan (-sU)           : Scan UDP ports.${NC}"
    echo -e "${YELLOW}3)${NC} ${GREEN}Version Detection (-sV)  : Detect service versions.${NC}"
    echo -e "${YELLOW}4)${NC} ${GREEN}OS Detection (-O)        : Determine the target OS.${NC}"
    echo -e "${YELLOW}5)${NC} ${GREEN}Ping Scan (-sn)          : Discover live hosts only.${NC}"
    echo -e "${YELLOW}6)${NC} ${GREEN}Comprehensive Scan       : (-sS -sV -O -A) for a detailed scan.${NC}"
    echo -e "${YELLOW}7)${NC} ${GREEN}Custom nmap options      : Enter your own options, if u smart.${NC}"
    echo -e "${YELLOW}0)${NC} ${GREEN}Exit the tool${NC}"
    echo -n "Enter your choice: "
}

# loop to allow multiple option selections.
while true; do
    show_menu
    read CHOICE
    case "$CHOICE" in
        1)
            SCAN_OPTIONS+=" -sS"
            echo -e "${GREEN}SYN Scan (-sS) selected.${NC}"
            ;;
        2)
            SCAN_OPTIONS+=" -sU"
            echo -e "${GREEN}UDP Scan (-sU) selected.${NC}"
            ;;
        3)
            SCAN_OPTIONS+=" -sV"
            echo -e "${GREEN}Version Detection (-sV) selected.${NC}"
            ;;
        4)
            SCAN_OPTIONS+=" -O"
            echo -e "${GREEN}OS Detection (-O) selected.${NC}"
            ;;
        5)
            SCAN_OPTIONS+=" -sn"
            echo -e "${GREEN}Ping Scan (-sn) selected.${NC}"
            ;;
        6)
            # comprehensive scan overrides any previous selections.
            SCAN_OPTIONS=" -sS -sV -O -A"
            echo -e "${GREEN}Comprehensive Scan selected.${NC}"
            break
            ;;
        7)
            read -p "Enter your custom nmap options: " CUSTOM_OPTS
            SCAN_OPTIONS+=" $CUSTOM_OPTS"
            echo -e "${GREEN}Custom options added.${NC}"
            break
            ;;
        0)
            echo -e "${RED}Exiting the tool. Cya1337!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Select a valid number from the menu.${NC}"
            ;;
    esac

    # ask if the user wants to add more options.
    read -p "Do you want to add another option? (y/n): " MORE
    if [[ "$MORE" != "y" && "$MORE" != "Y" ]]; then
        break
    fi
done

# construct the final nmap command.
CMD="nmap"
if [ -n "$PORTS" ]; then
    CMD+=" -p $PORTS"
fi
CMD+="$SCAN_OPTIONS $TARGET"

# display the final command (for transparency) and execute it.
echo -e "\n${CYAN}The following nmap command will be executed:${NC}"
echo -e "${YELLOW}$CMD${NC}"
echo ""
read -p "Press Enter to execute the scan..." DUMMY
eval $CMD