#!/bin/bash
#######################################################################
# Copyright (C) 2019 by ibrahim SEN <ibrahim@promek.net>
#
# https://github.com/promek/px-dns-da2cp
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>
#######################################################################

usage() {
    echo "Usage   : px-dns-da2cp.sh COMMAND DOMAIN [--nshost] [--ipaddr]"
    echo "Example : "
    echo "   px-dns-da2cp.sh sync example.com --nshost ns1 --ipaddr 192.168.1.1"
    echo "   px-dns-da2cp.sh delete example.com"
    echo
    exit 0
}

source /opt/px-dns-da2cp/config.sh

now() {
    echo $(date +"%b %e %T")
}

bash_run() {
local output=$( bash <<EOF
$1
EOF
)
echo "$output"
}

sync_dns() {
    host=$1
    pass=$2
    domain=$3
    ip=$4

    exist=$( bash_run "sshpass -p \"${pass}\" ssh -oStrictHostKeyChecking=no -p ${port} root@${host} \"whmapi1 dumpzone domain=${domain} | grep 'result: 1' \"" )

    if [ -z $exist ]; then
        result=$( bash_run "sshpass -p \"${pass}\" ssh -oStrictHostKeyChecking=no -p ${port} root@${host} \"whmapi1 adddns domain=${domain} ip=${ip}\"" )
        $DEBUG && echo "$(now) Add dns zone ${domain} to ${host}" >> $LOGFILE
        $DEBUG && echo "$result" >> $LOGFILE
    else 
        $DEBUG && echo "$(now) Zone already exist ${domain} on ${host}" >> $LOGFILE
        $DEBUG && echo "${exist}" >> $LOGFILE
    fi

    result=$( bash_run "rsync -avz --chown=named:named --chmod=600 -e \"sshpass -p '${pass}' ssh -oStrictHostKeyChecking=no -p ${port}\" /var/named/${domain}.db root@${host}:/var/named" )
    $DEBUG && echo "$(now) Sync dns zone ${domain}.db to ${host}" >> $LOGFILE
    $DEBUG && echo "$result" >> $LOGFILE

    result=$( bash_run "sshpass -p \"${pass}\" ssh -oStrictHostKeyChecking=no -p ${port} root@${host} \"rndc reload ${domain} IN internal;rndc reload ${domain} IN external;rndc flushname ${domain}\"" )
    $DEBUG && echo "$(now) Reload dns zone ${domain} on ${host}" >> $LOGFILE
    $DEBUG && echo "$result" >> $LOGFILE
}

delete_dns() {
    host=$1
    pass=$2
    domain=$3

    result=$( bash_run "sshpass -p \"${pass}\" ssh -oStrictHostKeyChecking=no -p ${port} root@${host} \"whmapi1 killdns domain=${domain}\"" )
    $DEBUG && echo "$(now) Delete dns zone ${domain} on ${host}" >> $LOGFILE
    $DEBUG && echo "$result" >> $LOGFILE
}

ipaddr=$( head -1 /usr/local/directadmin/data/admin/ip.list ) #server ip address
nshost="all"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --nshost)
    nshost="$2"
    shift
    shift
    ;;
    --ipaddr)
    ipaddr="$2"
    shift
    shift
    ;;
    --default)
    DEFAULT=YES
    shift
    ;;
    *)   
    POSITIONAL+=("$1") 
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"


if [ -z "$1" ] || [ $1 = "-h" ] || [ -z "$2" ] ; then
    usage
fi

cmd=$1
domain=$2

if [ $cmd = "sync" ] ; then
    if [ $nshost = "all" ] ; then
        for ns in "${!host[@]}" ; do
            sync_dns ${host[$ns]} ${pass[$ns]} $domain $ipaddr
        done
    else
        sync_dns ${host[$nshost]} ${pass[$nshost]} $domain $ipaddr
    fi
fi

if [ $cmd = "delete" ] ; then
    if [ $nshost = "all" ] ; then
        for ns in "${!host[@]}" ; do
            delete_dns ${host[$ns]} ${pass[$ns]} $domain
        done
    else
        delete_dns ${host[$nshost]} ${pass[$nshost]} $domain
    fi
fi
