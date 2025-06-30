# Utiliser l'image de base Alpine
FROM alpine:3.18

# Arguments pour la création de l'utilisateur SSH
ARG SSH_USER=devops
ARG SSH_PASSWORD=12345678
ENV PUPPET_VERSION=8.10.0

RUN apk update && \
    apk add --no-cache \
    python3 \
    py3-pip \
    supervisor \
    openssh \
    openrc \
    wget \
    ruby \
    ruby-dev \
    ruby-bundler \
    make \
    gcc \
    g++ \
    libc-dev \
    bash \
    shadow \
    augeas-dev \
    ruby-json \
    ruby-etc \
    ruby-ffi \
    git \
    && rm -rf /var/cache/apk/*

# Install Puppet and its dependencies
RUN gem install --no-document \
    facter \
    hiera \
    deep_merge \
    puppet:${PUPPET_VERSION} \
    r10k \
    && mkdir -p /etc/puppetlabs/puppet \
    && mkdir -p /opt/puppetlabs/puppet/cache \
    && echo '[main]' > /etc/puppetlabs/puppet/puppet.conf \
    && echo 'logdir = /var/log/puppet' >> /etc/puppetlabs/puppet/puppet.conf \
    && echo 'rundir = /var/run/puppet' >> /etc/puppetlabs/puppet/puppet.conf \
    && echo 'ssldir = $vardir/ssl' >> /etc/puppetlabs/puppet/puppet.conf \
    && mkdir -p /var/log/puppet \
    && mkdir -p /var/run/puppet

# --- Configuration du Serveur SSH (inchangé) ---
RUN ssh-keygen -A && \
    sed -i 's/#PasswordAuthentication prohibit-password/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    adduser -D -s /bin/bash ${SSH_USER} && \
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd

# --- Configuration de l'agent Puppet (inchangé) ---
RUN mkdir -p /etc/puppetlabs/puppet
#COPY puppet.conf /etc/puppetlabs/puppet/puppet.conf

# --- Configuration d'OpenRC (modifié) ---
RUN mkdir -p /run/openrc && touch /run/openrc/softlevel
# Copier notre nouveau script de service personnalisé pour puppet
COPY alpine/puppet.initd /etc/init.d/puppet
# Rendre le script de service exécutable
RUN chmod +x /etc/init.d/puppet
# Ajouter les services au runlevel par défaut
RUN rc-update add sshd default
RUN rc-update add puppet default

# --- Point d'entrée (inchangé) ---
COPY alpine/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]