#!/bin/bash

start_daemons() {
  # start rozo agent
  /etc/init.d/rozofs-manager-agent start
  # start rozo export
  if [ "$(grep -c '\(volumes\|exports\) *= *( *) *;' /etc/rozofs/export.conf)" != "2" ]; then
    /etc/init.d/rozofs-exportd start
  fi
  # start rozo storage
  if [ "$(grep -c 'storages *= *( *) *;' /etc/rozofs/storage.conf)" != "1" ]; then
    /etc/init.d/rozofs-storaged start
  fi
  # start rozo mounts
  awk '$1 == "rozofsmount" {print $2}' /etc/fstab |
    while read mount; do
      mkdir -p "$mount"
      mount "$mount"
    done
}

stop_daemons() {
  awk '$1 == "rozofsmount" {print $2}' /etc/fstab |
    while read mount; do
      umount "$mount"
    done
  /etc/init.d/rozofs-storaged stop
  /etc/init.d/rozofs-exportd stop
  /etc/init.d/rozofs-manager-agent stop
}

# start logging
/bin/busybox syslogd
tail -F /var/log/messages 2>/dev/null &

trap stop_daemons EXIT
start_daemons
wait $!
