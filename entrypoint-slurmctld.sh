#!/usr/bin/env bash

set -e

echo "---> Starting the MUNGE Authentication service (munged) ..."
gosu munge /usr/sbin/munged

echo "---> Waiting for slurmdbd to become active before starting slurmctld ..."
until 2>/dev/null >/dev/tcp/slurmdbd/6819; do
    echo "-- slurmdbd is not available.  Sleeping ..."
    sleep 2
done
echo "-- slurmdbd is now active ..."

echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
exec gosu slurm /usr/sbin/slurmctld -i -Dvvv
