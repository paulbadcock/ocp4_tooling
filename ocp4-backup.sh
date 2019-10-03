#!/bin/bash
# Quick way to backup OCP4 ETCD data via cron
#
# Paul Badcock - Oct 3, 2019

CLUSTERNAME=${1}

test_clustername() {
  case ${CLUSTERNAME} in
    nonprod)
      ETCD_HOST="etcd-0.cluster.domain"
      ETCD_USER="core"
      ETCD_KEYFILE="keyfile"
      LOCAL_BACKUP_DIR="/backup/cluster-ocp/"
      BACKUP_FILE="ocp-${CLUSTERNAME}-`date +%F`-backup.tgz"
      ;;
    another)
      echo "another"
      ;;
    *)
      echo "Specify an cluster name"
      exit 1
      ;;
  esac
}

error_exit() {
  echo "$1" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
  exit "${2:-1}"  ## Return a code specified by $2 or 1 by default.
}

move_data() {
  ssh -i ${ETCD_KEYFILE} ${ETCD_USER}@${ETCD_HOST} "sudo /usr/local/bin/etcd-snapshot-backup.sh ./assets/backup/snapshot.db; sudo chown -R core ./assets; tar -czf ${BACKUP_FILE} ./assets; rm -rf ./assets" 2>&1 &> /dev/null || error_exit "Unable to compress remote backup file"
  scp -i ${ETCD_KEYFILE} ${ETCD_USER}@${ETCD_HOST}:./${BACKUP_FILE} ${LOCAL_BACKUP_DIR} 2>&1 &> /dev/null || error_exit "Unable to copy remote backup locally"
  ssh -i ${ETCD_KEYFILE} ${ETCD_USER}@${ETCD_HOST} "rm -f ./${BACKUP_FILE}" 2>&1 &> /dev/null || error_exit "Unable to remove remote backup"
}

test_clustername
move_data
