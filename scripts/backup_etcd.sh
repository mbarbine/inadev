#!/bin/bash

#Verify KUBE context

# Backup etcd data
kubectl exec -n kube-system etcd-master -- /bin/sh -c "ETCDCTL_API=3 etcdctl snapshot save /var/lib/etcd/snapshot.db --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key"

# Upload snapshot to S3
aws s3 cp /var/lib/etcd/snapshot.db s3://$S3_BUCKET/etcd-backups/snapshot-$(date +%F_%T).db

echo "Etcd snapshot backup completed."
