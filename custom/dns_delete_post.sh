#!/bin/bash

da_domain=$( env | grep domain= | cut -d= -f2)

queue="/opt/px-dns-da2cp/custom/queue.atf"

if [ $( wc -l < ${queue} ) -eq 0 ]; then
    echo "> ${queue}" > $queue
fi

newtask="/opt/px-dns-da2cp/px-dns-da2cp.sh delete ${da_domain}"

oldtask="$( tail -1 $queue )"
if ! [ "${newtask}" = "${oldtask}" ] ; then
    echo $newtask >> $queue
fi

jobid=$( /usr/bin/atq | awk '{print $1}' )

if [ -z $jobid ]; then
    /usr/bin/at now + 5 minutes < $queue
else
    /usr/bin/atrm $jobid
    /usr/bin/at now + 5 minutes < $queue
fi
