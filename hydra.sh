#!/bin/bash

# clears the terminal and shows the title in color.
clear

echo ""
echo ""
cat << "EOF" | lolcat
 ██░ ██▓██   ██▓▓█████▄  ██▀███   ▄▄▄
▓██░ ██▒▒██  ██▒▒██▀ ██▌▓██ ▒ ██▒▒████▄
▒██▀▀██░ ▒██ ██░░██   █▌▓██ ░▄█ ▒▒██  ▀█▄
░▓█ ░██  ░ ▐██▓░░▓█▄   ▌▒██▀▀█▄  ░██▄▄▄▄██
░▓█▒░██▓ ░ ██▒▓░░▒████▓ ░██▓ ▒██▒ ▓█   ▓██▒
 ▒ ░░▒░▒  ██▒▒▒  ▒▒▓  ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
 ▒ ░▒░ ░▓██ ░▒░  ░ ▒  ▒   ░▒ ░ ▒░  ▒   ▒▒ ░
 ░  ░░ ░▒ ▒ ░░   ░ ░  ░   ░░   ░   ░   ▒
 ░  ░  ░░ ░        ░       ░           ░  ░
        ░ ░      ░
EOF

# welcome and instructions.
echo ""
# Print "Lets proceed:" in bold cyan.
echo -e "\033[1;36mLets proceed:\033[0m"
echo ""
# Print the description in bold yellow.
echo -e "\033[1;33mNo need to manually compile commands.
Follow the prompts, select your target and choose one or more scan options.\033[0m"
echo ""
echo ""

# function to display available services
display_services() {
    # Print the service selection header in bold magenta.
    echo -e "\033[1;35mSelect the service to target:\033[0m"
    echo ""
    echo "1) FTP"
    echo "2) SSH"
    echo "3) Telnet"
    echo "4) HTTP"
    echo "5) HTTPS"
    echo "6) SMB"
    echo "7) RDP"
    echo "8) MySQL"
    echo "9) PostgreSQL"
    echo "10) SMTP"
    echo "11) IMAP"
    echo "12) POP3"
    echo "13) VNC"
    echo "14) SNMP"
    echo "15) Redis"
    echo "16) MongoDB"
    echo "17) LDAP"
    echo "18) SIP"
    echo "19) Oracle"
    echo "20) Subversion"
    echo "21) Teamspeak"
    echo "22) VMware-Auth"
    echo "23) XMPP"
    echo "24) Custom"
}

# function to get user input for service-specific options
get_service_options() {
    case $service in
        1) service_name="ftp";;
        2) service_name="ssh";;
        3) service_name="telnet";;
        4) service_name="http";;
        5) service_name="https";;
        6) service_name="smb";;
        7) service_name="rdp";;
        8) service_name="mysql";;
        9) service_name="postgres";;
        10) service_name="smtp";;
        11) service_name="imap";;
        12) service_name="pop3";;
        13) service_name="vnc";;
        14) service_name="snmp";;
        15) service_name="redis";;
        16) service_name="mongodb";;
        17) service_name="ldap";;
        18) service_name="sip";;
        19) service_name="oracle";;
        20) service_name="svn";;
        21) service_name="teamspeak";;
        22) service_name="vmauthd";;
        23) service_name="xmpp";;
        24)
            read -p "Enter custom service name: " service_name
            ;;
        *)
            echo "Invalid selection."
            exit 1
            ;;
    esac
}

# function to prompt for username input method
get_username_input() {
    echo "Select username input method:"
    echo "  1) Single username (-l)"
    echo "  2) Username list file (-L)"
    read -p "Enter option number: " user_option

    case $user_option in
        1)
            read -p "Enter username: " username
            user_flag="-l $username"
            ;;
        2)
            read -p "Enter path to username list file: " user_file
            if [ ! -f "$user_file" ]; then
                echo "Username file does not exist. Exiting."
                exit 1
            fi
            user_flag="-L $user_file"
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
}

# function to prompt for password input method
get_password_input() {
    echo "Select password input method:"
    echo "  1) Single password (-p)"
    echo "  2) Password list file (-P)"
    read -p "Enter option number: " pass_option

    case $pass_option in
        1)
            read -s -p "Enter password: " password
            echo
            pass_flag="-p $password"
            ;;
        2)
            read -p "Enter path to password list file: " pass_file
            if [ ! -f "$pass_file" ]; then
                echo "Password file does not exist. Exiting."
                exit 1
            fi
            pass_flag="-P $pass_file"
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
}

# function to prompt for common Hydra options
get_common_options() {
    read -p "Enter target IP or hostname: " target
    read -p "Enter port (leave blank for default): " port
    read -p "Enter number of parallel tasks (default is 16): " tasks
    read -p "Enter path to output file (leave blank for no output file): " output_file
}

# function to construct the Hydra command
construct_hydra_command() {
    hydra_cmd="hydra $user_flag $pass_flag"
    if [ -n "$tasks" ]; then
        hydra_cmd+=" -t $tasks"
    fi
    if [ -n "$output_file" ]; then
        hydra_cmd+=" -o $output_file"
    fi
    if [ -n "$port" ]; then
        hydra_cmd+=" -s $port"
    fi
    hydra_cmd+=" $target $service_name"
}

# function to colorize Hydra output
colorize_output() {
    while IFS= read -r line; do
        if [[ $line == *"login:"* && $line == *"password:"* ]]; then
            # Successful attempt
            echo -e "\033[0;32m$line\033[0m"  # Green
        elif [[ $line == *"[ERROR]"* || $line == *"denied"* ]]; then
            # Errors or access denied
            echo -e "\033[0;31m$line\033[0m"  # Red
        else
            # Default color
            echo "$line"
        fi
    done
}

# function to prompt for command execution
prompt_execution() {
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    echo -e "Generated Hydra command: ${GREEN}$hydra_cmd${NC}"
    read -p "Do you want to execute this command? (y/n): " execute
    if [[ $execute =~ ^[Yy]$ ]]; then
        echo "Executing: $hydra_cmd"
        $hydra_cmd 2>&1 | colorize_output
    else
        echo "Command execution aborted."
    fi
}

# main script execution
display_services
read -p "Enter the number corresponding to the service: " service
get_service_options
get_username_input
get_password_input
get_common_options
construct_hydra_command
prompt_execution