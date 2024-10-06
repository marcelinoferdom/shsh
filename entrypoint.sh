#!/bin/bash

# Define proxy configurations for each session
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

  # Start running the Jaguar miner
  ./Jaguar --disable-gpu --algorithm verushash --pool stratum+tcp://138.197.29.207:4449 --wallet RW7q4an3QCeRH89sqrGcHKopjTX1Uj4oFT.NORTHAMERICA --cpu-threads "$(nproc)"--proxy $username:$password@$proxy_ip:$proxy_port &

  # Store the process ID (PID) of ccminer
  ccminer_pid=$!

  # Sleep for 7000 seconds and then change the proxy
  sleep 7000

  # Kill the current Jaguar process
  kill -2 $ccminer_pid

  # Wait for the process to terminate gracefully
  wait $ccminer_pid

  # Select a random proxy from the list
  proxy="${proxies[RANDOM % ${#proxies[@]}]}"
  echo "Changing to new proxy: $proxy"

  # Run again with the new proxy
  run_ccminer "$proxy"
}

# Start with a random proxy
initial_proxy="${proxies[RANDOM % ${#proxies[@]}]}"
echo "Starting with initial proxy: $initial_proxy"
run_ccminer "$initial_proxy"
