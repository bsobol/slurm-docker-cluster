FROM rockylinux:8

LABEL org.opencontainers.image.source="https://github.com/bsobol/slurm-docker-cluster" \
      org.opencontainers.image.title="slurm-docker-cluster" \
      org.opencontainers.image.description="Slurm Docker cluster on Rocky Linux 8" \
      org.label-schema.docker.cmd="docker-compose up -d" \
      maintainer="Bartosz Sobol"

ARG SLURM_TAG
ARG GOSU_VERSION

RUN set -ex \
    && dnf makecache \
    && dnf install -y epel-release \
    && dnf -y update \
    && dnf -y install dnf-plugins-core \
    && dnf config-manager --set-enabled powertools \
    && dnf -y install \
       nano htop mc wget git \
       make \
       gcc gcc-c++\
       gnupg \
       munge munge-devel \
       http-parser-devel \
       json-c-devel \
       readline readline-devel \
       python3 python3-devel python3-pip \
       mariadb-devel \
       psmisc findutils \
       net-tools bind-utils \
       bash-completion \
       apptainer \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN alternatives --set python /usr/bin/python3

RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && gpgconf --kill all \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -ex \
    && git clone -b ${SLURM_TAG} --single-branch --depth=1 https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin  --libdir=/usr/lib64 \
    && make -j$(nproc) install \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm \
    && groupadd -r --gid=990 slurm \
    && useradd -r -g slurm --uid=990 slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/run/slurmdbd \
        /var/lib/slurmd \
        /var/log/slurm \
    && touch /var/lib/slurmd/node_state \
        /var/lib/slurmd/front_end_state \
        /var/lib/slurmd/job_state \
        /var/lib/slurmd/resv_state \
        /var/lib/slurmd/trigger_state \
        /var/lib/slurmd/assoc_mgr_state \
        /var/lib/slurmd/assoc_usage \
        /var/lib/slurmd/qos_usage \
        /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* \
    && /sbin/create-munge-key

RUN set -ex \
    && mkdir \
        /data \
        /data/scratch \
        /data/storage \
    && groupadd --gid=1000 user \
    && useradd  -m -g user --uid=1000 user

# slurmdbd config file
COPY ./etc/slurm/slurmdbd.conf /etc/slurm/slurmdbd.conf
RUN set -ex \
    && chown slurm:slurm /etc/slurm/slurmdbd.conf \
    && chmod 600 /etc/slurm/slurmdbd.conf
