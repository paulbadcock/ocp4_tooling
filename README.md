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

If you need to change your NTP resources from generic internet sources you can use custom machine configs.

Filename | Usage
---------|------
99-ntp-sources-master.yaml | Master config
99-ntp-sources-worker.yaml | Worker config

Each of these files use label selectors in the metadata to apply to either the master or worker nodes.

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


### Setting up custom configs

Modify your server lines to your custom NTP sources as needed then copy your contents into a [URLencode tool](https://www.urlencoder.org/).

Replace the line data line in the yaml file(s) on line 21 with
```
              data:,URLENCODEDSRING......
```

Note: the **data:,** is critical to operation


### Applying NTP settings

With your custom configs you need to apply them to OpenShift. Soon as these machine configurations are applied the configs will be rendered to a new version of the master or worker machine config pools and rolling upgrades will start. If you wish you can apply one or both at the same time as a cluster-admin depending on the confidence.

To apply the config to the workers

`oc apply -f 99-ntp-sources-worker.yaml`

To apply the config to the masters

`oc apply -f 99-ntp-sources-master.yaml`

You should then see nodes cordon/disable scheduling and drain pods from their workloads

`oc get nodes`

And confirm it

```
NAME                             STATUS                     ROLES    AGE     VERSION
etcd-0.cluster.domain            Ready                      master   2d21h   v1.13.4+12ee15d4a
etcd-1.cluster.domain            Ready                      master   2d21h   v1.13.4+12ee15d4a
etcd-2.cluster.domain            Ready                      master   2d21h   v1.13.4+12ee15d4a
worker-0.cluster.domain          Ready,SchedulingDisabled   worker   2d21h   v1.13.4+12ee15d4a
worker-1.cluster.domain          Ready                      worker   2d21h   v1.13.4+12ee15d4a
worker-2.cluster.domain          Ready                      worker   2d21h   v1.13.4+12ee15d4a
```

This process will continue for all the nodes in the cluster. You should be able to confirm their time sources after reboot by running the `chronyc sources` command via SSH.

Or as a part of one big command

```
for i in {etcd-0,etcd-1,etcd-2,worker-0,worker-1,worker-2}; do ssh -i cluster_rsa_key core@${i}.cluster.domain 'chronyc sources'; done
```

And you should see something like

```
210 Number of sources = 3
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* ntpsource1                    1   7   377   128    -25us[  -33us] +/-  764us
^- ntpsource2                    3   6   377     1    -25us[  -25us] +/- 7064us
^- ntpsource3                    3   6   377    59   +112us[ +112us] +/- 6193us
^- ntpsource4                    1   6   377    59    +34us[  +45us] +/-  834us
```
