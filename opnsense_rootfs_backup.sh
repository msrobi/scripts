#!/bin/sh
mount /mnt/backup
dump -C16 -b64 -0uanL -h0 -f - /dev/gpt/rootfs | gzip -2 > /mnt/backup/OPNSense/rootfs-`date +%m%d%Y`.dump.gz
#dump -C16 -b64 -0uanL -h0 -f - /dev/ad4s1b | gzip -2 > /mnt/backup/OPNSense/ad4s1b-`date +%m%d%Y`.dump.gz
tar -cjf /mnt/backup/OPNSense/root_fs-`date +%m%d%Y`.tar.bz2 --exclude=/dev --exclude=/mnt --exclude=/proc /
find /mnt/backup/OPNSense -mtime +30 | grep dump | while read x;do rm -f "$x";done
find /mnt/backup/OPNSense -mtime +30 | grep root_fs | while read x;do rm -f "$x";done
umount /mnt/backup
