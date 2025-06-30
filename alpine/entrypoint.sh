#!/bin/sh
set -e
openrc sysinit
echo "Démarrage du service SSHD..."
rc-service sshd start
echo "Démarrage de l'agent Puppet..."
rc-service puppet start
echo "Services démarrés. Affichage des logs..."
tail -F /var/log/messages /var/log/puppet/agent.log