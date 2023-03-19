#!/bin/sh
set -e

# Default values
: ${ASTERISK_ARGS:="-fp"}

# Get the local network and update *.conf files
: ${LOCAL_NET="$(ip route | grep "src $MAINIP" | awk '{print $1}' | tr -d "\n")"}
sed -i "s#LOCAL_NET#${LOCAL_NET}#g" /etc/asterisk/*

# Substitute the environment variables in Asterisk *.conf template files
for TMPL in /etc/asterisk/*.tmpl
do
  if [ -f ${TMPL} ]; then
    envsubst < ${TMPL} > ${TMPL%.*}
    rm -f ${TMPL}
  fi
done

# Check if we run the container for the first time
if [ -f /firstrun ]; then
  echo 'First run of the container. Creating user asterisk'
  mkdir -p /var/spool/asterisk /etc/asterisk /var/log/asterisk
  addgroup -S -g ${ASTERISK_GUID:-1000} asterisk
  adduser -D -S -h /var/spool/asterisk -G asterisk -u ${ASTERISK_UUID:-1000} asterisk
  chown -R asterisk:asterisk /var/spool/asterisk /etc/asterisk /var/log/asterisk /var/lib/asterisk
  rm -rf /firstrun
fi

# If we were given arguments, run them instead
if [ $# -gt 0 ]; then
   exec "$@"
fi

# Run Asterisk
exec /usr/sbin/asterisk ${ASTERISK_ARGS}

