# Slurm Docker Cluster

## Getting Started

To get up and running with Slurm in Docker, make sure you have the following tools installed:

- **[Docker](https://docs.docker.com/get-docker/)**
- **[Docker Compose](https://docs.docker.com/compose/install/)**

## Containers and Volumes

This setup consists of the following containers:

- **mysql**: Stores job and cluster data.
- **slurmdbd**: Manages the Slurm database.
- **slurmctld**: The Slurm controller responsible for job and resource management.
- Compute nodes (running `slurmd`).

### Volumes:

- `etc_munge` mounted to `/etc/munge`
- `etc_slurm` mounted to `/etc/slurm`
- `var_lib_mysql` mounted to `/var/lib/mysql`
- `var_log_slurm` mounted to `/var/log/slurm`
- `scratch` mounted to `/data/scratch`
- `$STORAGE_PATH` bound to `/data/storage`

## Building the Docker Image

The version of the Slurm project and the Docker build process can be simplified
by using a `.env` file, which will be automatically picked up by Docker Compose.

Update the `SLURM_TAG` and `IMAGE_TAG` found in the `.env` file and build
the image:

```bash
docker compose build
```

Alternatively, you can build the Slurm Docker image locally by specifying the
[SLURM_TAG](https://github.com/SchedMD/slurm/tags) as a build argument and
tagging the container with a version ***(IMAGE_TAG)***:

```bash
docker build --build-arg SLURM_TAG="slurm-21-08-6-1" -t slurm-docker-cluster:21.08.6 .
```

## Starting the Cluster

Once the image is built, deploy the cluster with the default version of slurm
using Docker Compose:

```bash
docker compose up -d
```

To specify a specific version and override what is configured in `.env`, specify
the `IMAGE_TAG`:

```bash
IMAGE_TAG=21.08.6 docker compose up -d
```

This will start up all containers in detached mode. You can monitor their status using:

```bash
docker compose ps
```
For real-time cluster logs, use:

```bash
docker compose logs -f
```

## Accessing the Cluster

To interact with the Slurm controller, open a shell inside the `slurmctld` container:

```bash
docker exec -itu user slurmctld bash
```
## Cluster Management

### Stopping and Restarting:

Stop the cluster without removing the containers:

```bash
docker compose stop
```

Restart it later:

```bash
docker compose start
```

### Deleting the Cluster:

To completely remove the containers and associated volumes:

```bash
docker compose down -v
```
