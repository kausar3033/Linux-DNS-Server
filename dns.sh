# update os and install bind9

        sudo apt update

        sudo apt install -y bind9 bind9utils bind9-doc dnsutils

        cd /etc/bind


# configure dns forwarding

        cp named.conf.options named.conf.options.bak
 # Before echo please delete old file

        echo -e "acl trustedclients {
                localhost;
                localnets;
                192.168.68.0/24;
        };

        options {
                directory "/var/cache/bind";

                recursion yes;
                allow-query { trustedclients; };
                allow-query-cache { trustedclients; };
                allow-recursion { trustedclients; };

                forwarders {
                        8.8.8.8;
                        8.8.4.4;
                };


                dnssec-validation no;

                listen-on-v6 port 53 { ::1; };
                listen-on port 53 { 127.0.0.1; 192.168.68.93; };
        };" >> named.conf.options



# check configuration

        sudo named-checkconf



# define zone files

        cp named.conf.local named.conf.local.bak

        echo -e "zone "stepup.com.bd" {
                type master;
                file "/etc/bind/db.stepup.com.bd";
        };
        
 # define reverse zone files

        zone "68.168.192.in-addr.arpa" {
                type master;
                file "/etc/bind/db.192.168.68";
        };" >> named.conf.local



# check configuration

        sudo named-checkconf



# create forward lookup zone

        echo -e ";
        ; BIND data file for local loopback interface
        ;
        $TTL    604800
        @       IN      SOA     test.stepup.com.bd. admin.stepup.com.bd. (
                                      3         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                 604800 )       ; Negative Cache TTL
        ;
        @       IN      NS      prince-supershop.test.io.

        dev	IN	A	192.168.68.93" >> db.stepup.com.bd



# check configuration

        named-checkzone ibos.io db.test.io



#create reverse lookup zone

        echo -e ";
        ; BIND reverse data file for test.local zone
        ;
        $TTL    604800
        @       IN      SOA     prince-supershop.test.io. admin.test.io. (
                                      2         ; Serial
                                 604800         ; Refresh
                                  86400         ; Retry
                                2419200         ; Expire
                                 604800 )       ; Negative Cache TTL
        ;
        @       IN      NS      prince-supershop.test.io.

        20	IN	PTR	test.test.local." >> db.192.168.2



# check configuration

        sudo named-checkzone 2.168.192.in-addr.arpa db.192.168.2


# edit the server dns entry to use its own dns server

        sudo vim /etc/netplan/00-installer-config.yaml
#change ip address of the dns server entry then save and exit.
        sudo netplan apply

# enable and restart bindi9

        sudo systemctl restart bind9
