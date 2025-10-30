#!/usr/bin/env bash

set -e

docker exec slurmctld bash -c "/usr/bin/sacctmgr --immediate add cluster name=C" && \
docker-compose restart slurmdbd slurmctld
