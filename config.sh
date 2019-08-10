#!/bin/bash

declare -A host
declare -A pass

DEBUG=false
LOGFILE=/var/log/px-dns-da2cp.log

port="22"

host=( 
    [ns1]="ns1.cpdnsonlyserver.tld" 
    [ns2]="ns2.cpdnsonlyserver.tld"
) 

pass=(
    [ns1]="root-password"
    [ns2]="root-password"
)
