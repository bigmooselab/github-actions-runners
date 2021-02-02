ARG FROM=ubuntu:focal
FROM ${FROM}
LABEL maintainer="scottjbowen@icloud.com"

# Set versions
ARG RUNNER_VERSION="2.276.1"
ARG DOCKER_COMPOSE_VERSION="1.27.4"

# ENV REPOSITORY_URL=""
ENV ACCESS_TOKEN=$ACCESS_TOKEN
ENV RUNNER_WORK_DIRECTORY="work"
ENV RUNNER_LABELS="node12"
ENV RUNNER_ALLOW_RUNASROOT=true
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

# Install required packages
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git \
  awscli \
  curl \
  tar \
  unzip \
  apt-transport-https \
  ca-certificates \
  sudo \
  gnupg-agent \
  software-properties-common \
  build-essential \
  zlib1g-dev \
  gettext \
  liblttng-ust0 \
  libcurl4-openssl-dev \
  openssh-client \
  jq \
  wget \
  dirmngr \
  openssh-client \
  python3 \
  python3-venv \
  python3-dev \
  lsb-release \
  supervisor \
  iputils-ping && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o- | sh && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

# Install Docker-Compose
RUN curl -L -o /usr/local/bin/docker-compose \
  "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" && \
  chmod +x /usr/local/bin/docker-compose

# Install Node.js 12.x as required by Fantasia and GraphQL
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
  && sudo apt-get install -y nodejs

# Install Sonar Scanner
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216-linux.zip \
  && unzip sonar-scanner-cli-4.5.0.2216-linux.zip -d /var/opt/

RUN mkdir -p /home/runner ${AGENT_TOOLSDIRECTORY}

WORKDIR /home/runner

# Install GitHub Actions Runner service
RUN RUNNER_VERSION=${RUNNER_VERSION:-$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')} \
  && curl -L -O https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && tar -zxf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && rm -f actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && ./bin/installdependencies.sh \
  && chown -R root: /home/runner \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]