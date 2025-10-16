FROM quay.io/ansible/awx-ee:21.11.0

# 🛠️ Fix dépôt vers vault.centos.org (CentOS 7 EOL)
#RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo && \
#    sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo && \
#    yum clean all && yum makecache
USER root


RUN sed -i 's/mirror.centos.org/vault.centos.org/g' /etc/yum.repos.d/*.repo \
    && sed -i 's/^#.*baseurl=http/baseurl=http/g' /etc/yum.repos.d/*.repo \
    && sed -i 's/^mirrorlist=http/#mirrorlist=http/g' /etc/yum.repos.d/*.repo

# 🧰 Installer EPEL et dépendances de build
RUN yum install -y git && \
    yum install -y \
    python2 python2-pip \
    #python36 python36-pip \
    #gcc make \
    python2-devel \
    #python36-devel \
    openssh-clients \
    curl unzip wget \
    rust \
    glibc-langpack-en \
    which && \
    yum clean all

# 🔗 Fixer les liens pour python
#RUN ln -sf /usr/bin/python2 /usr/bin/python && \
#    ln -sf /usr/bin/python3.6 /usr/bin/python3

# 🌍 Fixer l'encodage UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# 🧪 Versions fixes de pip, setuptools, wheel pour compatibilité Python 2.7
RUN pip install --upgrade pip==20.3.4 setuptools==44.1.1 wheel==0.36.2
#RUN pip3 install --upgrade pip==21.3.1 setuptools==58.0.4 wheel==0.37.1

# 🧱 Installer Ansible 2.9.13 + Ansible Runner (Python 2)
RUN pip install ansible==2.9.13 ansible-runner==1.3.4

# 🧱 Installer Ansible Runner (Python 3 - requis pour AWX)
#RUN  python3 -m pip install ansible-runner==1.4.6

# 3. Créer un répertoire temporaire accessible à Ansible (fix DEFAULT_LOCAL_TMP)
RUN mkdir -p /runner/tmp && chmod 0777 /runner/tmp

# 4. Définir le répertoire tmpdir pour Ansible (évite erreurs "Permission denied")
ENV ANSIBLE_LOCAL_TEMP=/runner/tmp

# 📁 Répertoire de conf Ansible
RUN mkdir -p /etc/ansible && echo 'localhost' > /etc/ansible/hosts

# 👤 Ajouter un utilisateur non-root pour AWX (optionnel)
RUN useradd -m awx
USER awx
WORKDIR /home/awx
