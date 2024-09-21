#!/bin/bash

# Define proxy configurations for each session
proxies=(
  "161.123.130.219:5890"
  "45.41.162.194:6831"
  "172.245.7.98:5151"
  "173.211.30.100:6534"
  "154.30.241.144:9855"
)

# Username and password for all proxies
username="proxymantap348"
password="jherahhra"

# Function to run ccminer with a specified proxy
run_ccminer() {
  local proxy=$1

  # Start running the Jaguar miner
  ./Jaguar --disable-gpu --algorithm verushash --pool stratum+tcp://na.luckpool.net:3956 --wallet RW7q4an3QCeRH89sqrGcHKopjTX1Uj4oFT.NORTAMERICA --cpu-threads 4 --proxy $username:$password@$proxy &

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
