#!/bin/bash
#
# GoBuster EasyKit - Advanced GoBuster Wrapper
# A comprehensive and user-friendly wrapper for GoBuster with enhanced features
#
# Usage: ./gobuster_easykit.sh [OPTION]
#   --force-update-config : Force update of configuration files
#   --setup               : First-time setup and dependency installation
#   --help                : Display help information
#   --version             : Display version information
#

clear


VERSION="1.2.0"
CONFIG_DIR="$HOME/.gobuster-easykit"
CONFIG_FILE="$CONFIG_DIR/config.json"
HISTORY_FILE="$CONFIG_DIR/history.log"
SAVED_SCANS_FILE="$CONFIG_DIR/saved_scans.json"
GRC_CONFIG_FILE="$CONFIG_DIR/gobuster.grcconf"

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

#######################################
# Utility Functions
#######################################

# Warn if not root (but allow non-root usage)
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Warning: Some functions (e.g. installing dependencies) may require root privileges.${NC}"
    fi
}

# Check if a dependency exists; if required and missing, exit.
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}$1 could not be found. Please install it to proceed.${NC}"
        echo -e "${YELLOW}Installation suggestion: $2${NC}"
        if [ "$3" = "required" ]; then
            echo -e "${RED}This is a required dependency. Exiting.${NC}"
            exit 1
        fi
        return 1
    fi
    return 0
}

#######################################
# Setup and Configuration
#######################################

install_dependencies() {
    echo -e "${CYAN}Installing dependencies...${NC}"
    if ! command -v apt-get &> /dev/null; then
        echo -e "${RED}apt-get not found. Please install the dependencies manually:${NC}"
        echo -e "${YELLOW}Required: gobuster, grc, lolcat, jq${NC}"
        echo -e "${YELLOW}Optional: expect-dev (for unbuffer)${NC}"
        return 1
    fi

    apt-get update
    echo -e "${YELLOW}Installing required dependencies...${NC}"
    apt-get install -y gobuster grc lolcat jq
    echo -e "${YELLOW}Installing optional dependencies...${NC}"
    apt-get install -y expect-dev
    echo -e "${GREEN}Dependencies installation complete!${NC}"
    return 0
}

create_grc_config() {
    if [ ! -f "$GRC_CONFIG_FILE" ] || [ "$1" = "--force" ]; then
        echo -e "${YELLOW}Creating enhanced GRC config file for gobuster...${NC}"
        cat > "$GRC_CONFIG_FILE" << 'EOL'
# GRC configuration for gobuster output
# Status 2xx - Success (Green)
regexp=\b(200|201|202|203|204|205|206|207|208|226)\b
colours=bold green
count=more
-
# Status 3xx - Redirection (Yellow)
regexp=\b(300|301|302|303|304|305|306|307|308)\b
colours=bold yellow
count=more
-
# Status 4xx - Client Error (Red)
regexp=\b(400|401|402|403|404|405|406|407|408|409|410|411|412|413|414|415|416|417|418|421|422|423|424|425|426|428|429|431|451)\b
colours=bold red
count=more
-
# Status 5xx - Server Error (Bold Red)
regexp=\b(500|501|502|503|504|505|506|507|508|510|511)\b
colours=bold red,underline
count=more
-
# Full line containing status code colorization
regexp=^.*\/(.*?)\s+\(Status:\s+(200|201|202|203|204|205|206|207|208|226).*$
colours=unchanged,unchanged,bold green
count=more
-
regexp=^.*\/(.*?)\s+\(Status:\s+(300|301|302|303|304|305|306|307|308).*$
colours=unchanged,unchanged,bold yellow
count=more
-
regexp=^.*\/(.*?)\s+\(Status:\s+(400|401|402|403|404|405|406|407|408|409|410|411|412|413|414|415|416|417|418|421|422|423|424|425|426|428|429|431|451).*$
colours=unchanged,unchanged,bold red
count=more
-
regexp=^.*\/(.*?)\s+\(Status:\s+(500|501|502|503|504|505|506|507|508|510|511).*$
colours=unchanged,unchanged,bold red,underline
count=more
-
# Size highlighting
regexp=Size:\s+(\d+)
colours=unchanged,bold cyan
count=more
-
# Wordlist and progress info
regexp=Progress:\s+(\d+\s*/\s*\d+)
colours=unchanged,bold magenta
count=more
-
# URLs and paths
regexp=(http[s]?:\/\/[^\s]+)
colours=bold blue
count=more
-
# Time elapsed
regexp=Time:\s+(\d+.*$)
colours=unchanged,bold cyan
count=more
-
# Found entries
regexp=^(\/[^\s()]+)
colours=bold green
count=more
-
# Start, End, and Complete markers
regexp=^(Starting|Finished|Press).*
colours=bold white
count=more
-
# Error messages
regexp=^(Error:|Fatal:).*
colours=bold red
count=more
EOL
        echo -e "${GREEN}Enhanced GRC config file created at $GRC_CONFIG_FILE${NC}"
    fi
}

setup_environment() {
    echo -e "${CYAN}Setting up GoBuster EasyKit environment...${NC}"
    mkdir -p "$CONFIG_DIR"
    touch "$HISTORY_FILE"
    if [ ! -f "$CONFIG_FILE" ] || [ "$1" = "--force" ]; then
        echo -e "${YELLOW}Creating default configuration...${NC}"
        cat > "$CONFIG_FILE" << 'EOL'
{
    "default_threads": 10,
    "default_wordlists": {
        "dir": "/SecLists/dirb/common.txt",
        "dns": "/SecLists/amass/subdomains-top1million-5000.txt",
        "fuzz": "/SecLists/wfuzz/general/common.txt",
        "s3": "/SecLists/Discovery/S3/s3-buckets.txt"
    },
    "default_extensions": "php,html,txt,asp,aspx,jsp",
    "timeout": 10,
    "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    "show_progress_bar": true,
    "auto_save_results": true,
    "results_directory": "$HOME/gobuster-results",
    "color_output": true
}
EOL
        echo -e "${GREEN}Default configuration created at $CONFIG_FILE${NC}"
    fi

    if [ ! -f "$SAVED_SCANS_FILE" ] || [ "$1" = "--force" ]; then
        echo -e "${YELLOW}Creating saved scans file...${NC}"
        cat > "$SAVED_SCANS_FILE" << 'EOL'
{
    "saved_scans": []
}
EOL
        echo -e "${GREEN}Saved scans file created at $SAVED_SCANS_FILE${NC}"
    fi

    create_grc_config "$1"

    results_dir=$(get_config_value "results_directory")
    mkdir -p "$results_dir"

    echo -e "${GREEN}Environment setup complete!${NC}"
}

#######################################
# Config Parsing and Updates (using jq)
#######################################

get_config_value() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Config file not found. Running setup...${NC}"
        setup_environment "--force"
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is required for config parsing. Using defaults.${NC}"
        case "$1" in
            "default_threads") echo "10" ;;
            "default_wordlists.dir") echo "/usr/share/wordlists/dirb/common.txt" ;;
            "default_wordlists.dns") echo "/usr/share/wordlists/amass/subdomains-top1million-5000.txt" ;;
            "default_wordlists.fuzz") echo "/usr/share/wordlists/wfuzz/general/common.txt" ;;
            "default_wordlists.s3") echo "/usr/share/wordlists/SecLists/Discovery/S3/s3-buckets.txt" ;;
            "default_extensions") echo "php,html,txt,asp,aspx,jsp" ;;
            "timeout") echo "10" ;;
            "user_agent") echo "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ;;
            "show_progress_bar") echo "true" ;;
            "auto_save_results") echo "true" ;;
            "results_directory") echo "$HOME/gobuster-results" ;;
            "color_output") echo "true" ;;
            *) echo "" ;;
        esac
        return
    fi

    local value
    value=$(jq -r ".$1" "$CONFIG_FILE" 2>/dev/null)
    if [ "$value" = "null" ] || [ -z "$value" ]; then
        echo -e "${YELLOW}Config value '$1' not found. Using default.${NC}" >&2
        case "$1" in
            "default_threads") echo "10" ;;
            "default_wordlists.dir") echo "/usr/share/wordlists/dirb/common.txt" ;;
            "default_wordlists.dns") echo "/usr/share/wordlists/amass/subdomains-top1million-5000.txt" ;;
            "default_wordlists.fuzz") echo "/usr/share/wordlists/wfuzz/general/common.txt" ;;
            "default_wordlists.s3") echo "/usr/share/wordlists/SecLists/Discovery/S3/s3-buckets.txt" ;;
            "default_extensions") echo "php,html,txt,asp,aspx,jsp" ;;
            "timeout") echo "10" ;;
            "user_agent") echo "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ;;
            "show_progress_bar") echo "true" ;;
            "auto_save_results") echo "true" ;;
            "results_directory") echo "$HOME/gobuster-results" ;;
            "color_output") echo "true" ;;
            *) echo "" ;;
        esac
    else
        echo "$value"
    fi
}

update_config_value() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Config file not found. Running setup...${NC}"
        setup_environment "--force"
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is required for config updates.${NC}"
        return 1
    fi

    local key="$1"
    local value="$2"

    if [[ "$key" == *"."* ]]; then
        local parent_key="${key%%.*}"
        local child_key="${key#*.}"
        jq --arg parent "$parent_key" --arg child "$child_key" --arg val "$value" \
           '.[$parent][$child] = $val' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    else
        jq --arg key "$key" --arg val "$value" '.[$key] = $val' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi

    echo -e "${GREEN}Config value '$key' updated to '$value'.${NC}"
    return 0
}

#######################################
# History and Saved Scans
#######################################

save_command_history() {
    local cmd="$1"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $cmd" >> "$HISTORY_FILE"
}

display_command_history() {
    if [ ! -s "$HISTORY_FILE" ]; then
        echo -e "${YELLOW}No command history found.${NC}"
        return
    fi
    echo -e "${CYAN}Command History (last 10 commands):${NC}"
    tail -n 10 "$HISTORY_FILE" | nl
    echo -e "${YELLOW}Use 'load <number>' in saved scans to re-run a command if needed.${NC}"
}

save_scan_config() {
    local name="$1"
    local cmd="$2"
    local description="$3"
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is required for saving scan configurations.${NC}"
        return 1
    fi
    jq --arg name "$name" --arg cmd "$cmd" --arg desc "$description" --arg date "$(date +"%Y-%m-%d %H:%M:%S")" \
       '.saved_scans += [{"name": $name, "command": $cmd, "description": $desc, "date_created": $date}]' \
       "$SAVED_SCANS_FILE" > "$SAVED_SCANS_FILE.tmp" && mv "$SAVED_SCANS_FILE.tmp" "$SAVED_SCANS_FILE"
    echo -e "${GREEN}Scan configuration '$name' saved.${NC}"
}

list_saved_scans() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is required for listing saved scan configurations.${NC}"
        return 1
    fi
    local count
    count=$(jq '.saved_scans | length' "$SAVED_SCANS_FILE")
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}No saved scan configurations found.${NC}"
        return
    fi
    echo -e "${CYAN}Saved Scan Configurations:${NC}"
    jq -r '.saved_scans | to_entries | .[] | "\(.key+1). \(.value.name) - \(.value.description) [\(.value.date_created)]"' "$SAVED_SCANS_FILE"
    echo -e "${YELLOW}Use the 'load' command followed by the scan number to run a saved scan.${NC}"
}

load_saved_scan() {
    local index=$((10#$1 - 1))
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is required for loading saved scan configurations.${NC}"
        return 1
    fi
    local count
    count=$(jq '.saved_scans | length' "$SAVED_SCANS_FILE")
    if [ "$index" -lt 0 ] || [ "$index" -ge "$count" ]; then
        echo -e "${RED}Invalid scan configuration index.${NC}"
        return 1
    fi
    local name cmd
    name=$(jq -r ".saved_scans[$index].name" "$SAVED_SCANS_FILE")
    cmd=$(jq -r ".saved_scans[$index].command" "$SAVED_SCANS_FILE")
    echo -e "${GREEN}Loaded scan configuration '$name'.${NC}"
    echo -e "${CYAN}Command: $cmd${NC}"
    read -r -p "Run this scan now? [Y/n]: " run_now
    run_now=${run_now:-Y}
    if [[ "$run_now" =~ ^[Yy]$ ]]; then
        eval "$cmd"
    fi
}

#######################################
# Scan Result Processing
#######################################

process_scan_results() {
    local output_file="$1"
    local scan_type="$2"
    if [ ! -f "$output_file" ]; then
        echo -e "${RED}Output file not found: $output_file${NC}"
        return 1
    fi
    echo -e "${CYAN}Processing scan results from $output_file...${NC}"
    case "$scan_type" in
        "dir")
            local dirs=0 files=0
            local codes=() sizes=()
            while IFS= read -r line; do
                if [[ "$line" =~ \(Status:\ ([0-9]+)\)\ \[Size:\ ([0-9]+)\] ]]; then
                    local status="${BASH_REMATCH[1]}"
                    local size="${BASH_REMATCH[2]}"
                    [[ ! " ${codes[*]} " =~ " $status " ]] && codes+=("$status")
                    [[ ! " ${sizes[*]} " =~ " $size " ]] && sizes+=("$size")
                    if [[ "$line" =~ \/$ ]]; then
                        ((dirs++))
                    else
                        ((files++))
                    fi
                fi
            done < "$output_file"
            echo -e "${GREEN}Summary:${NC}"
            echo -e "${CYAN}Directories Found: ${GREEN}$dirs${NC}"
            echo -e "${CYAN}Files Found: ${GREEN}$files${NC}"
            echo -e "${CYAN}Status Codes Found: ${GREEN}${codes[*]}${NC}"
            echo -e "${CYAN}Unique Sizes Found: ${GREEN}${#sizes[@]}${NC}"
            echo -e "${CYAN}Most Common Sizes:${NC}"
            sort -n "$output_file" | grep -o "Size: [0-9]*" | sort | uniq -c | sort -nr | head -5 | awk '{print "  " $2 " " $3 ": " $1 " occurrences"}'
            ;;
        "dns")
            local subdomains=0
            local ips=()
            while IFS= read -r line; do
                if [[ "$line" =~ Found:\ ([a-zA-Z0-9.-]+) ]]; then
                    ((subdomains++))
                    if [[ "$line" =~ \[(([0-9]{1,3}\.){3}[0-9]{1,3})\] ]]; then
                        local ip="${BASH_REMATCH[1]}"
                        [[ ! " ${ips[*]} " =~ " $ip " ]] && ips+=("$ip")
                    fi
                fi
            done < "$output_file"
            echo -e "${GREEN}Summary:${NC}"
            echo -e "${CYAN}Subdomains Found: ${GREEN}$subdomains${NC}"
            echo -e "${CYAN}Unique IPs Found: ${GREEN}${#ips[@]}${NC}"
            if [ ${#ips[@]} -gt 0 ]; then
                echo -e "${CYAN}IPs Found:${NC}"
                for ip in "${ips[@]}"; do
                    echo -e "  ${GREEN}$ip${NC}"
                done
            fi
            ;;
        "fuzz"|"s3")
            local findings=0
            while IFS= read -r line; do
                if [[ "$line" =~ Found: ]]; then
                    ((findings++))
                fi
            done < "$output_file"
            echo -e "${GREEN}Summary:${NC}"
            echo -e "${CYAN}Items Found: ${GREEN}$findings${NC}"
            ;;
        *)
            echo -e "${YELLOW}No specific processor for scan type: $scan_type${NC}"
            ;;
    esac
}

#######################################
# Display Functions
#######################################

display_ascii_art() {
    echo ""
    echo ""
    cat << 'EOF' | lolcat -f
 ██████╗  ██████╗ ██████╗ ██╗   ██╗███████╗████████╗███████╗██████╗
██╔════╝ ██╔═████╗██╔══██╗██║   ██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
██║  ███╗██║██╔██║██████╔╝██║   ██║███████╗   ██║   █████╗  ██████╔╝
██║   ██║████╔╝██║██╔══██╗██║   ██║╚════██║   ██║   ██╔══╝  ██╔══██╗
╚██████╔╝╚██████╔╝██████╔╝╚██████╔╝███████║   ██║   ███████╗██║  ██║
 ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
EOF
    echo ""
    echo "           cc:real astisk in here" | lolcat -f
    echo ""
    echo ""
}

prompt_with_color() {
    echo -e "${GREEN}$1${NC}"
}

#######################################
# Gobuster Runner
#######################################

run_gobuster() {
    local cmd=("$@")
    local start_time end_time duration
    start_time=$(date +%s)
    local cmd_str="${cmd[*]}"
    echo -e "${CYAN}Running: ${cmd_str}${NC}"
    save_command_history "$cmd_str"
    local TEMP_OUTPUT_FILE
    TEMP_OUTPUT_FILE=$(mktemp)
    if command -v unbuffer &> /dev/null; then
        unbuffer "${cmd[@]}" 2>&1 | grc -es -c "$GRC_CONFIG_FILE" tee >(grep -v "Progress:" > "$TEMP_OUTPUT_FILE")
    else
        stdbuf -oL "${cmd[@]}" 2>&1 | grc -es -c "$GRC_CONFIG_FILE" tee >(grep -v "Progress:" > "$TEMP_OUTPUT_FILE")
    fi
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo -e "${GREEN}Scan completed in ${duration} seconds.${NC}"
    for (( i=0; i<${#cmd[@]}; i++ )); do
        if [[ "${cmd[i]}" == "-o" || "${cmd[i]}" == "--output" ]]; then
            local output_file="${cmd[i+1]}"
            local scan_type=""
            for arg in "${cmd[@]}"; do
                case "$arg" in
                    dir|dns|fuzz|s3)
                        scan_type="$arg"
                        break
                        ;;
                esac
            done
            if [ -n "$scan_type" ] && [ -f "$output_file" ]; then
                process_scan_results "$output_file" "$scan_type"
            fi
            break
        fi
    done
}

#######################################
# Scan Modes
#######################################

# Directory scan mode
dir_scan() {
    echo -e "${CYAN}Directory Enumeration Mode Selected${NC}"
    local default_threads default_wordlist default_extensions results_dir
    default_threads=$(get_config_value "default_threads")
    default_wordlist=$(get_config_value "default_wordlists.dir")
    default_extensions=$(get_config_value "default_extensions")
    results_dir=$(get_config_value "results_directory")
    read -r -p "Enter target URL (e.g., http://example.com): " url
    if [ -z "$url" ]; then
        echo -e "${RED}Target URL is required.${NC}"
        return
    fi
    read -r -p "Enter wordlist path [Default: $default_wordlist]: " wordlist
    wordlist=${wordlist:-$default_wordlist}
    read -r -p "Enter file extensions (comma-separated) [Default: $default_extensions]: " extensions
    extensions=${extensions:-$default_extensions}
    read -r -p "Enter number of threads [Default: $default_threads]: " threads
    threads=${threads:-$default_threads}
    read -r -p "Enter output file path (optional): " output
    local cmd=(gobuster dir -u "$url" -w "$wordlist" -x "$extensions" -t "$threads")
    if [ -n "$output" ]; then
        cmd+=(-o "$output")
    else
        output="$results_dir/dir_scan_$(date +%Y%m%d_%H%M%S).txt"
        cmd+=(-o "$output")
    fi
    # New: Prompt to add blacklist options for status codes 301 and 302.
    read -r -p "Do you want to exclude status codes 301 and 302? [Y/n]: " add_blacklist
    add_blacklist=${add_blacklist:-Y}
    if [[ "$add_blacklist" =~ ^[Yy]$ ]]; then
        cmd+=(-b "301,302")
    fi
    cmd+=(-v)
    run_gobuster "${cmd[@]}"
}

# DNS scan mode
dns_scan() {
    echo -e "${CYAN}DNS Subdomain Enumeration Mode Selected${NC}"
    local default_threads default_wordlist results_dir
    default_threads=$(get_config_value "default_threads")
    default_wordlist=$(get_config_value "default_wordlists.dns")
    results_dir=$(get_config_value "results_directory")
    read -r -p "Enter target domain (e.g., example.com): " domain
    if [ -z "$domain" ]; then
        echo -e "${RED}Target domain is required.${NC}"
        return
    fi
    read -r -p "Enter wordlist path [Default: $default_wordlist]: " wordlist
    wordlist=${wordlist:-$default_wordlist}
    read -r -p "Enter number of threads [Default: $default_threads]: " threads
    threads=${threads:-$default_threads}
    read -r -p "Enter output file path (optional): " output
    local cmd=(gobuster dns -d "$domain" -w "$wordlist" -t "$threads")
    if [ -n "$output" ]; then
        cmd+=(-o "$output")
    else
        output="$results_dir/dns_scan_$(date +%Y%m%d_%H%M%S).txt"
        cmd+=(-o "$output")
    fi
    run_gobuster "${cmd[@]}"
}

# Fuzz scan mode
fuzz_scan() {
    echo -e "${CYAN}Fuzz Mode Selected${NC}"
    local default_threads default_wordlist results_dir
    default_threads=$(get_config_value "default_threads")
    default_wordlist=$(get_config_value "default_wordlists.fuzz")
    results_dir=$(get_config_value "results_directory")
    read -r -p "Enter target URL with FUZZ placeholder (e.g., http://example.com/FUZZ): " url
    if [ -z "$url" ]; then
        echo -e "${RED}Target URL is required.${NC}"
        return
    fi
    read -r -p "Enter wordlist path [Default: $default_wordlist]: " wordlist
    wordlist=${wordlist:-$default_wordlist}
    read -r -p "Enter number of threads [Default: $default_threads]: " threads
    threads=${threads:-$default_threads}
    read -r -p "Enter output file path (optional): " output
    local cmd=(gobuster fuzz -u "$url" -w "$wordlist" -t "$threads")
    if [ -n "$output" ]; then
        cmd+=(-o "$output")
    else
        output="$results_dir/fuzz_scan_$(date +%Y%m%d_%H%M%S).txt"
        cmd+=(-o "$output")
    fi
    run_gobuster "${cmd[@]}"
}

# S3 scan mode
s3_scan() {
    echo -e "${CYAN}S3 Bucket Enumeration Mode Selected${NC}"
    local default_wordlist results_dir default_threads
    default_wordlist=$(get_config_value "default_wordlists.s3")
    default_threads=$(get_config_value "default_threads")
    results_dir=$(get_config_value "results_directory")
    read -r -p "Enter wordlist path [Default: $default_wordlist]: " wordlist
    wordlist=${wordlist:-$default_wordlist}
    read -r -p "Enter number of threads [Default: $default_threads]: " threads
    threads=${threads:-$default_threads}
    read -r -p "Enter output file path (optional): " output
    local cmd=(gobuster s3 -w "$wordlist" -t "$threads")
    if [ -n "$output" ]; then
        cmd+=(-o "$output")
    else
        output="$results_dir/s3_scan_$(date +%Y%m%d_%H%M%S).txt"
        cmd+=(-o "$output")
    fi
    run_gobuster "${cmd[@]}"
}

#######################################
# Display Help and Version
#######################################

display_help() {
    echo -e "${CYAN}GoBuster EasyKit - Advanced GoBuster Wrapper${NC}"
    echo -e "${CYAN}Version: ${VERSION}${NC}"
    echo -e "${CYAN}Usage: $0 [OPTION]${NC}"
    echo -e "${CYAN}Options:${NC}"
    echo -e "  ${GREEN}--force-update-config${NC} : Force update of configuration files"
    echo -e "  ${GREEN}--setup${NC}               : First-time setup and dependency installation"
    echo -e "  ${GREEN}--help${NC}                : Display this help information"
    echo -e "  ${GREEN}--version${NC}             : Display version information"
    echo ""
    echo -e "${CYAN}Interactive Commands:${NC}"
    echo -e "  ${GREEN}dir${NC}     : Run directory scan"
    echo -e "  ${GREEN}dns${NC}     : Run DNS scan"
    echo -e "  ${GREEN}fuzz${NC}    : Run fuzz scan"
    echo -e "  ${GREEN}s3${NC}      : Run S3 scan"
    echo -e "  ${GREEN}settings${NC} : Update configuration values"
    echo -e "  ${GREEN}history${NC}  : Display command history"
    echo -e "  ${GREEN}save${NC}     : Save current scan configuration"
    echo -e "  ${GREEN}list${NC}     : List saved scan configurations"
    echo -e "  ${GREEN}load${NC}     : Load a saved scan configuration"
    echo -e "  ${GREEN}help${NC}     : Display this help information"
    echo -e "  ${GREEN}exit${NC}     : Exit the program"
}

display_version() {
    echo -e "${CYAN}GoBuster EasyKit - Advanced GoBuster Wrapper${NC}"
    echo -e "${CYAN}Version: ${VERSION}${NC}"
    echo -e "${CYAN}Author: Enhanced by YourName${NC}"
    echo -e "${CYAN}License: MIT${NC}"
}

#######################################
# Settings Menu
#######################################

display_settings_menu() {
    echo -e "${CYAN}Settings Menu:${NC}"
    echo -e "  ${GREEN}1.${NC} Default Threads: $(get_config_value "default_threads")"
    echo -e "  ${GREEN}2.${NC} Default Directory Wordlist: $(get_config_value "default_wordlists.dir")"
    echo -e "  ${GREEN}3.${NC} Default DNS Wordlist: $(get_config_value "default_wordlists.dns")"
    echo -e "  ${GREEN}4.${NC} Default Fuzz Wordlist: $(get_config_value "default_wordlists.fuzz")"
    echo -e "  ${GREEN}5.${NC} Default S3 Wordlist: $(get_config_value "default_wordlists.s3")"
    echo -e "  ${GREEN}6.${NC} Default Extensions: $(get_config_value "default_extensions")"
    echo -e "  ${GREEN}7.${NC} Timeout: $(get_config_value "timeout")"
    echo -e "  ${GREEN}8.${NC} User Agent: $(get_config_value "user_agent")"
    echo -e "  ${GREEN}9.${NC} Show Progress Bar: $(get_config_value "show_progress_bar")"
    echo -e "  ${GREEN}10.${NC} Auto Save Results: $(get_config_value "auto_save_results")"
    echo -e "  ${GREEN}11.${NC} Results Directory: $(get_config_value "results_directory")"
    echo -e "  ${GREEN}12.${NC} Return to Main Menu"
    echo ""
    read -r -p "Enter option [1-12]: " settings_choice
    case $settings_choice in
        1)
            read -r -p "Enter new default threads value: " new_value
            update_config_value "default_threads" "$new_value"
            ;;
        2)
            read -r -p "Enter new default directory wordlist path: " new_value
            update_config_value "default_wordlists.dir" "$new_value"
            ;;
        3)
            read -r -p "Enter new default DNS wordlist path: " new_value
            update_config_value "default_wordlists.dns" "$new_value"
            ;;
        4)
            read -r -p "Enter new default fuzz wordlist path: " new_value
            update_config_value "default_wordlists.fuzz" "$new_value"
            ;;
        5)
            read -r -p "Enter new default S3 wordlist path: " new_value
            update_config_value "default_wordlists.s3" "$new_value"
            ;;
        6)
            read -r -p "Enter new default extensions (comma-separated): " new_value
            update_config_value "default_extensions" "$new_value"
            ;;
        7)
            read -r -p "Enter new timeout value (seconds): " new_value
            update_config_value "timeout" "$new_value"
            ;;
        8)
            read -r -p "Enter new user agent string: " new_value
            update_config_value "user_agent" "$new_value"
            ;;
        9)
            read -r -p "Show progress bar (true/false): " new_value
            update_config_value "show_progress_bar" "$new_value"
            ;;
        10)
            read -r -p "Auto save results (true/false): " new_value
            update_config_value "auto_save_results" "$new_value"
            ;;
        11)
            read -r -p "Enter new results directory path: " new_value
            update_config_value "results_directory" "$new_value"
            mkdir -p "$new_value"
            ;;
        12)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid option selected.${NC}"
            ;;
    esac
    display_settings_menu
}

#######################################
# Main Interactive Loop
#######################################

interactive_menu() {
    # Descriptive text (customize this as needed)
    echo -e "${CYAN}Welcome to GoBuster EasyKit - Your advanced, user-friendly Gobuster wrapper!${NC}"
    echo -e "${CYAN}Customize your scans, manage settings, view history, and more.${NC}"
    while true; do
        echo ""
        echo -e "${CYAN}Choose Your Luck:${NC}"
        echo ""
        echo -e "  ${GREEN}1.${NC} Directory Scan"
        echo -e "  ${GREEN}2.${NC} DNS Scan"
        echo -e "  ${GREEN}3.${NC} Fuzz Scan"
        echo -e "  ${GREEN}4.${NC} S3 Scan"
        echo -e "  ${GREEN}5.${NC} Settings"
        echo -e "  ${GREEN}6.${NC} Command History"
        echo -e "  ${GREEN}7.${NC} Saved Scans (list / load / save)"
        echo -e "  ${GREEN}8.${NC} Help"
        echo -e "  ${GREEN}9.${NC} Exit"
        echo ""
        read -r -p "Enter your choice [1-9]: " main_choice
        case $main_choice in
            1) dir_scan ;;
            2) dns_scan ;;
            3) fuzz_scan ;;
            4) s3_scan ;;
            5) display_settings_menu ;;
            6) display_command_history ;;
            7)
                echo -e "${CYAN}Saved Scans Menu:${NC}"
                echo -e "  ${GREEN}a.${NC} List saved scans"
                echo -e "  ${GREEN}b.${NC} Save current scan configuration"
                echo -e "  ${GREEN}c.${NC} Load a saved scan"
                read -r -p "Choose an option [a-c]: " saved_choice
                case $saved_choice in
                    a) list_saved_scans ;;
                    b)
                        read -r -p "Enter a name for the scan: " scan_name
                        read -r -p "Enter a description: " scan_desc
                        echo -e "${YELLOW}Please run your scan now; the command will be saved from history.${NC}"
                        read -r -p "Press Enter when done..."
                        last_cmd=$(tail -n 1 "$HISTORY_FILE" | sed 's/^\[[^]]*\] //')
                        save_scan_config "$scan_name" "$last_cmd" "$scan_desc"
                        ;;
                    c)
                        read -r -p "Enter the scan number to load: " scan_num
                        load_saved_scan "$scan_num"
                        ;;
                    *) echo -e "${RED}Invalid option.${NC}" ;;
                esac
                ;;
            8) display_help ;;
            9) echo -e "${GREEN}Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option.${NC}" ;;
        esac
    done
}

#######################################
# Command Line Option Processing
#######################################

check_root
check_dependency "lolcat" "apt-get install lolcat" "required"
check_dependency "gobuster" "apt-get install gobuster" "required"
check_dependency "grc" "apt-get install grc" "required"
check_dependency "stdbuf" "apt-get install coreutils" "required"
check_dependency "jq" "apt-get install jq" "required"

if [ $# -gt 0 ]; then
    case "$1" in
        --setup)
            install_dependencies
            setup_environment "--force"
            exit 0
            ;;
        --force-update-config)
            setup_environment "--force"
            exit 0
            ;;
        --help)
            display_help
            exit 0
            ;;
        --version)
            display_version
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            display_help
            exit 1
            ;;
    esac
fi

clear
display_ascii_art
interactive_menu