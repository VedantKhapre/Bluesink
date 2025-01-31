#!/bin/bash

# Script name for checking if we need to undo
SCRIPT_NAME="bluesink.sh"
COMBINED_SINK_NAME="multi_bluetooth"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

# Help function
show_help() {
    cat << EOF
Bluetooth Audio Sink Management Script

Usage: $0 [OPTION]

Options:
  --help, -h          Shows this help message and exit
  --create            Create a combined Bluetooth audio sink (default behavior)
  --undo              Undo the combined Bluetooth audio sink
  --list              List available Bluetooth sinks
  --status            Show current audio sink status

Examples:
  $0                  Create combined Bluetooth audio sink
  $0 --create         Same as default behavior
  $0 --undo           Remove combined Bluetooth audio sink
  $0 --list           Show available Bluetooth sinks
  $0 --status         Display current audio sink configuration

Purpose:
  Manages Bluetooth audio sinks by creating a combined sink
  that allows multiple Bluetooth audio devices to play simultaneously.

Requirements:
  - PulseAudio (pactl) must be installed
  - Bluetooth audio devices must be connected

EOF
}

# get all Bluetooth sinks
get_bluetooth_sinks() {
    pactl list short sinks | grep bluez_output | awk '{print $2}'
}

# list Bluetooth sinks
list_bluetooth_sinks() {
    local sinks
    sinks=$(get_bluetooth_sinks)

    if [[ -z "$sinks" ]]; then
        log "No Bluetooth sinks found."
        return 1
    fi

    echo "Available Bluetooth Sinks:"
    echo "$sinks" | while read -r sink; do
        echo "  - $sink"
    done
}

# show current audio sink status
show_audio_status() {
    echo "Current Default Sink:"
    pactl info | grep "Default Sink"

    echo -e "\nAll Sinks:"
    pactl list short sinks

    echo -e "\nCurrent Modules:"
    pactl list short modules | grep -E "combine-sink|bluez"
}

# check if combined sink already exists
combined_sink_exists() {
    pactl list short modules | grep -q "name=$COMBINED_SINK_NAME"
}

# load combined sink
create_combined_sink() {
    # Check if combined sink already exists
    if combined_sink_exists; then
        log "Combined sink already exists."
        return 1
    fi

    # Get Bluetooth sinks
    local sinks
    sinks=$(get_bluetooth_sinks)

    # Check if no Bluetooth sinks are found
    if [[ -z "$sinks" ]]; then
        log "Error: No Bluetooth devices found."
        return 1
    fi

    # Create a combined sink using all Bluetooth sinks
    local slaves
    slaves=$(echo "$sinks" | tr '\n' ',' | sed 's/,$//')

    if ! pactl load-module module-combine-sink sink_name="$COMBINED_SINK_NAME" slaves="$slaves"; then
        log "Failed to create combined sink."
        return 1
    fi

    log "Created combined sink with Bluetooth devices."
    return 0
}

# set the default sink to the combined sink
set_default_sink() {
    if ! pactl set-default-sink "$COMBINED_SINK_NAME"; then
        log "Failed to set default sink to $COMBINED_SINK_NAME."
        return 1
    fi

    log "Set default sink to $COMBINED_SINK_NAME."
    return 0
}

# undo the changes
undo_changes() {
    # Find and unload the specific module for the combined sink
    local module_id
    module_id=$(pactl list short modules | grep "name=$COMBINED_SINK_NAME" | awk '{print $1}')

    if [[ -n "$module_id" ]]; then
        if ! pactl unload-module "$module_id"; then
            log "Failed to unload combined sink module."
            return 1
        fi
        log "Undid: Removed the combined sink."
    else
        log "No combined sink module found to unload."
    fi

    # Reset default sink to the first Bluetooth device (if any)
    local first_bluetooth_sink
    first_bluetooth_sink=$(get_bluetooth_sinks | head -n 1)

    if [[ -n "$first_bluetooth_sink" ]]; then
        if ! pactl set-default-sink "$first_bluetooth_sink"; then
            log "Failed to set default sink back to $first_bluetooth_sink."
            return 1
        fi
        log "Set default sink back to $first_bluetooth_sink."
    else
        log "No Bluetooth device found to set as default."
    fi

    return 0
}

# Main logic for script
main() {
    case "$1" in
        --help|-h)
            show_help
            ;;
        --create)
            create_combined_sink && set_default_sink
            ;;
        --undo)
            undo_changes
            ;;
        --list)
            list_bluetooth_sinks
            ;;
        --status)
            show_audio_status
            ;;
        "")
            # Default behavior: create combined sink
            create_combined_sink && set_default_sink
            ;;
        *)
            echo "Error: Invalid option '$1'"
            show_help
            exit 1
            ;;
    esac
}

# Run the main function with all arguments
main "$@"
