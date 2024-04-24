#!/bin/bash

# Log file to monitor
log_file="/var/log/syslog"

# Function to extract and parse event string
parse_event() {
    # Putting space between the original output of the event and the readable information
    echo ""
    echo "__________________________________________________________________________________"

    # Extract event number from the input string
    event_number=$(echo "$1" | grep -oP '\.\K\d+(?=: )')

    # Parsing the input string and formatting time
    time_event="$(echo "${1%.*}" | date +"%d/%m/%y %H:%M:%S")" # Extract time without milliseconds and format as dd/mm/yy HH:MM:SS
    echo "time = \"$time_event\""

    # Get the machine name
    machine_name=$(hostname)
    echo "machine = \"$machine_name\""
    # get event number from the event string
    echo "event number = \"${event_number}\""

    # Check if the event contains the expected warning message
    if echo "$1" | grep -q "Warning Sensitive file opened for reading by non-trusted program"; then
        event_warning="Warning Sensitive file opened for reading by non-trusted program"
    else
        event_warning=$(echo "$1" | grep -oE 'Warning [^ ]+' | sed 's/Warning //')
    fi
    echo "event warning = \"$event_warning\""

    user_id=$(echo "$1" | grep -oE 'user_uid=[^ ]+' | sed 's/user_uid=//')
    echo "UserID = \"$user_id\""

    processes=$(echo "$1" | grep -oE 'process=[^ ]+' | sed 's/process=//' | sort | uniq)
    echo "processes = \"$processes\""

    process_exepath=$(echo "$1" | grep -oE 'proc_exepath=[^ ]+' | sed 's/proc_exepath=//')
    echo "process_exepath = \"$process_exepath\""

    # Extract and format parent processes
    parent_processes=$(echo "$1" | grep -oE 'parent=[^ ]+' | sed 's/parent=//' | awk '{$1=$1};1' | tac)
    parent="$(echo "$parent_processes" | tr '\n' ' ')"
    echo "parent = \"$parent\""

    command=$(echo "$1" | grep -oE 'command=[^ ]+' | sed 's/command=//')
    echo "command = \"$command\""

    terminal=$(echo "$1" | grep -oE 'terminal=[^ ]+' | sed 's/terminal=//')
    echo "terminal = \"$terminal\""

    container_id=$(echo "$1" | grep -oE 'container_id=[^ ]+' | sed 's/container_id=//')
    echo "container_id = \"$container_id\""

    container_name=$(echo "$1" | grep -oE 'container_name=[^ ]+' | sed 's/container_name=//' | tr -d ')')
    echo "container_name = \"$container_name\""
}

# Check the log file for the specified event string
if grep -q "Warning Sensitive file opened for reading by non-trusted program" "$log_file"; then
    # If the event string is found, get the corresponding line
    event_line=$(grep "Warning Sensitive file opened for reading by non-trusted program" "$log_file" | tail -n 1)
    # Call the function to parse the event
    parse_event "$event_line"
fi

