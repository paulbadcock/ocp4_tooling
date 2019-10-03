# OpenShift 4 - Tools

Collection of self published OpenShift 4 tools

## ocp4-backup.sh

Intended use is in a cron or other secheduled jobs to backup a cluster etcd via
  `ocp4-backup.sh clustername`
  
The clustername is used as a predefined list of clusters that provide 4 pieces of data

1. ETCD_HOST - What server to ssh to and preform the snapshot
2. ETCD_USER - The username (core in most cases) to ssh as
3. ETCD_KEYFILE - The ssh keyfile for the user
4. LOCAL_BACKUP_DIR - Full path of where to store the file
5. BACKUP_FILE - A way to customize the backup file name

Replicating the conditional test in the case like `nonprod` will provide a way to introduce multiple clusternames.
