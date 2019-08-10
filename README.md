# px-dns-da2cp

* Requirements for Centos7
```
$ yum install rsync at sshpass
$ service atd start
```

## install script on directadmin
```
$ wget https://github.com/promek/px-dns-da2cp/archive/master.zip
$ unzip ./master.zip -d /opt 
$ mv /opt/px-dns-da2cp-master /opt/px-dns-da2cp

$ chown diradmin:diradmin /opt/px-dns-da2cp -R
$ chmod 700 /opt/px-dns-da2cp -R
$ ln -s /opt/px-dns-da2cp/custom/dns_write_post.sh /usr/local/directadmin/scripts/custom/dns_write_post.sh
$ ln -s /opt/px-dns-da2cp/custom/dns_delete_post.sh /usr/local/directadmin/scripts/custom/dns_delete_post.sh
```
### finally, configure /opt/px-dns-da2cp/config.sh to your servers
