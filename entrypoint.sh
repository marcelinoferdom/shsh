#!/bin/bash

# Define proxy configurations for each session
proxies=(
  "38.153.137.233:5541"
  "172.245.158.68:6021"
  "206.206.119.27:5938"
  "23.94.138.40:6314"
  "161.123.154.79:6609"
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
