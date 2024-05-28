#!/bin/bash

CONFIG_FILE="/var/www/html/config.txt"
UPLOADS_DIR="/var/www/html/uploads/"
LAST_SELECTED=""

# Ensure we use the default display, typically :0
export DISPLAY=:0

# Log file for debugging
LOG_FILE="vlc_script.log"

# Functions
start_vlc() {
    local video_file=$1

    # Close any existing VLC session
    pkill -f vlc
    sleep 2  # Wait for VLC to fully close

    # Get monitor 0 resolution and position
    MONITOR0_INFO=$(xrandr | grep -w "connected primary" | head -1 | grep -oP "\d+x\d+\+\d+\+\d+")
    MONITOR0_WIDTH=$(echo $MONITOR0_INFO | sed -r 's/^([0-9]+)x[0-9]+\+[0-9]+\+[0-9]+$/\1/')
    MONITOR0_HEIGHT=$(echo $MONITOR0_INFO | sed -r 's/^[0-9]+x([0-9]+)\+[0-9]+\+[0-9]+$/\1/')
    MONITOR0_X=$(echo $MONITOR0_INFO | sed -r 's/^[0-9]+x[0-9]+\+([0-9]+)\+[0-9]+$/\1/')
    MONITOR0_Y=$(echo $MONITOR0_INFO | sed -r 's/^[0-9]+x[0-9]+\+[0-9]+\+([0-9]+)$/\1/')

    # Log monitor info for debugging
    echo "$(date) MONITOR0_INFO: $MONITOR0_INFO" >> "$LOG_FILE"

    # Start VLC in fullscreen mode on the monitor 0 with aspect ratio fitting the screen
    cvlc --no-video-title-show --fullscreen --loop --aspect-ratio "${MONITOR0_WIDTH}:${MONITOR0_HEIGHT}" "$video_file" \
         --vout gl --avcodec-hw=any >> "$LOG_FILE" 2>&1 &
}

stop_vlc() {
    pkill -f vlc
    sleep 2  # Wait for VLC to fully close
}

process_config() {
    if [ -f "$CONFIG_FILE" ]; then
        local selected_file
        selected_file=$(cat "$CONFIG_FILE")
        if [ -z "$selected_file" ]; then
            # If the config is empty, stop VLC
            stop_vlc
            LAST_SELECTED=""
        elif [ "$UPLOADS_DIR$selected_file" != "$LAST_SELECTED" ]; then
            LAST_SELECTED="$UPLOADS_DIR$selected_file"
            start_vlc "$LAST_SELECTED"
        fi
    fi
}

# Initial setup
if [ ! -f "$CONFIG_FILE" ]; then
    echo "$(date) Configuration file ($CONFIG_FILE) not found." >> "$LOG_FILE"
    exit 1
fi

if [ ! -d "$UPLOADS_DIR" ]; then
    echo "$(date) Uploads directory ($UPLOADS_DIR) not found." >> "$LOG_FILE"
    exit 1
fi

if ! command -v inotifywait &> /dev/null; then
    echo "$(date) inotifywait could not be found, please install it with 'sudo apt-get install inotify-tools'" >> "$LOG_FILE"
    exit 1
fi

if ! command -v xrandr &> /dev/null; then
    echo "$(date) xrandr could not be found, please install it with 'sudo apt-get install x11-xserver-utils'" >> "$LOG_FILE"
    exit 1
fi

# Initial process
process_config

# Monitor the config file for changes
while inotifywait -e modify "$CONFIG_FILE"; do
    process_config
done