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

## NTP configuration

When you need to set your time sources to non pool resources you can use the machine configs

Filename | Usage
---------|------
99-ntp-sources-master.yaml | Master config
99-ntp-sources-worker.yaml | Worker config

In order to specify the time sources you need to take a sample chrony.conf file like below
```
server 0.rhel.pool.ntp.org iburst
server 1.rhel.pool.ntp.org iburst
server 2.rhel.pool.ntp.org iburst
server 3.rhel.pool.ntp.org iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony

```

Modify your server sources as needed then copy your contents into a [URLencode tool](https://www.urlencoder.org/).

Replace the line data line in the yaml file(s) on line 21 with
```
              data:,URLENCODEDSRING......
```

Note: the **data:,** is critical to operation
