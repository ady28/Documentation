#if you want to use replication with cert auth you will need a cert
#template that has server authentication and client authentication:
#one that has this is the Computer template (only machine on which it can be used cen request it)
#you can also modify the web template and add client auth (this can be requested on a machine and imported on another one)

#make sure you have on each host a cert with the dn set to CN=host.domain or the DNS name host.domain