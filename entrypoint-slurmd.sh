#!/usr/bin/env bash

set -e

echo "---> Starting the MUNGE Authentication service (munged) ..."
gosu munge /usr/sbin/munged

echo "---> Waiting for slurmctld to become active before starting slurmd..."
until 2>/dev/null >/dev/tcp/slurmctld/6817; do
    echo "-- slurmctld is not available.  Sleeping ..."
    sleep 2
done
echo "-- slurmctld is now active ..."

echo "---> Setting node hostname ..."
# hack to get container name/node id
# based on https://stackoverflow.com/questions/60480257/how-to-simply-scale-a-docker-compose-service-and-pass-the-index-and-count-to-eac/64799824#64799824
IP=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')
NAME=$(dig -x "$IP" +short | cut -d'.' -f1 )

# set new hostname based on the container name
gosu root hostname "$NAME"
echo "-- Hostnbame is now set to $(hostname -s) ..."

echo "---> Starting the Slurm Node Daemon (slurmd) ..."
exec /usr/sbin/slurmd -Dvvv
