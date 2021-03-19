#!/bin/bash
ns=production
name=sentry
hostname=$name.aws.dwos.com
secrets=./sentry/secrets.yaml

# Prepare namespace
if kubectl get namespace $ns > /dev/null 2>&1 ; then
        echo Namespace $ns already present
else
        echo Creating namespace $ns
        knubectl create namespace $ns
fi

# Make sure secrets are settup
if [ ! -f $secrets ] ; then
        echo "There must be a file '$secrets' present containing all the sensitive information. This is supposedly stored in KeePass."
        exit 1
fi

# Prevent reinstall
if helm list -n $ns -f $name | grep $name > /dev/null ; then
        echo "$name already installed on $ns, preventing over installation"
        exit 2
fi

# to import a previous DB, place it on a node and add the following to that command: --set postgresql.importdbPath="/path/to/db.dump" --set postgresql.importdbNode="name-of-node"
helm install $name ./sentry --timeout 30m --debug -n $ns -f ./sentry/values.yaml -f $secrets --set system.url="https://$hostname" --set ingress.hostname="$hostname"

