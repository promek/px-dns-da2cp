#!/bin/bash

source /opt/px-dns-da2cp/config.sh

da_domain=$( env | grep DOMAIN= | cut -d= -f2)
da_ip=$( env | grep DOMAIN_IP= | cut -d= -f2)

queue="/opt/px-dns-da2cp/custom/queue.atf"

if [ $( wc -l < ${queue} ) -eq 0 ]; then
    echo "> ${queue}" > $queue
fi

newtask="/opt/px-dns-da2cp/px-dns-da2cp.sh sync ${da_domain} --ipaddr ${da_ip}"

oldtask="$( tail -1 $queue )"
if ! [ "${newtask}" = "${oldtask}" ] ; then
    echo $newtask >> $queue
fi

jobid=$( /usr/bin/atq | awk '{print $1}' )

if [ -z $jobid ]; then
    /usr/bin/at now + $time minutes < $queue
else
    /usr/bin/atrm $jobid
    /usr/bin/at now + $time minutes < $queue
fi
