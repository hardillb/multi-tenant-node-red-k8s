#!/bin/sh

kubectl create secret generic kube-config \
  --from-file=config=`readlink -f ~/.kube/config` \
  --from-file=settings.js=`readlink -f manager/config/settings.js` \
  --dry-run=client --output=yaml > deployment/secret.yml

if [ -z "$1" ]
then
	rd=`hostname`.local
else
	rd=$1
fi

if [ -z "$2" ]
then
	reg=$2
else
	reg=""
fi

sed -i -e 's/private.example.com/$reg/g' deployment/deployment.yml
sed -i -e 's/example.com/$rd/g' deployment/deployment.yml
sed -i -e 's/example.com/$rd/g' deployment/ingress.yml
sed -i -e 's/example.com/$rd/g' custom-node-red/settings.js