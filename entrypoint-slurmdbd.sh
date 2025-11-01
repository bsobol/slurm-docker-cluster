#!/usr/bin/env bash

set -e

echo "---> Starting the MUNGE Authentication service (munged) ..."
gosu munge /usr/sbin/munged

echo "---> Starting the Slurm Database Daemon (slurmdbd) ..."
sleep 2
# TODO ensure db started
exec gosu slurm /usr/sbin/slurmdbd -Dvvv
