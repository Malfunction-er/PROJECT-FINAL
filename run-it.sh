#!/bin/bash

OSSEC_CMD="sudo /Users/malfunctioner_/Desktop/PROJECT-FINAL/bin/ossec-control"
SURICATA_CMD="sudo suricata -c /System/Volumes/Data/opt/homebrew/etc/suricata/suricata.yaml -i en0 --init-errors-fatal"
LOG_DIR="/Users/malfunctioner_/Desktop/PROJECT-FINAL/logs"
PROXYMAN_LOG_DIR="$LOG_DIR/proxyman_logs"
SURICATA_LOG_DIR="$LOG_DIR/suricata_logs"
OSSEC_LOG="$LOG_DIR/ossec.log"
ACTIVE_RESPONSES_LOG="$LOG_DIR/active-responses.log"
# APPLESCRIPT_APP="ProxymanSaveSession.scpt" 

mkdir -p "$PROXYMAN_LOG_DIR"

start_services() {
    echo "Starting OSSEC..."
    $OSSEC_CMD start
    echo "Starting Suricata..."
    $SURICATA_CMD &
    echo "Starting Proxyman..."
    open -a "Proxyman"
    echo "All services started."
}

stop_services() {
    echo "Stopping OSSEC..."
    $OSSEC_CMD stop
    echo "Stopping Suricata..."
    pkill -f "suricata"
    echo "Stopping Proxyman..."
    sudo pkill -f "proxyman"
    save_session
    echo "All services stopped."
}

save_session() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    SESSION_LOG="$PROXYMAN_LOG_DIR/proxyman_session_$TIMESTAMP.log"

    osascript -e 'tell application "Proxyman" to activate'
    osascript -e 'tell application "System Events" to tell process "Proxyman" to click menu bar item 3 of menu bar 1'
    osascript -e 'tell application "System Events" to tell process "Proxyman" to click menu item 11 of menu 1 of menu bar item 3 of menu bar 1'

    sleep 10
    osascript -e 'tell application "Proxyman" to quit'

}

clear_logs() {
    echo "Clearing all logs in $PROXYMAN_LOG_DIR and $SURICATA_LOG_DIR..."
    rm -f "$PROXYMAN_LOG_DIR"/* "$SURICATA_LOG_DIR"/*
    echo "Clearing OSSEC log and active responses log..."
    : > "$OSSEC_LOG"
    : > "$ACTIVE_RESPONSES_LOG"
    echo "All logs cleared."
}


case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    save-session)
        save_session
        ;;
    clear-logs)
        clear_logs
        ;;
    *)
        echo "Usage: $0 {start|stop|save-session|clear-logs}"
        exit 1
        ;;
esac
