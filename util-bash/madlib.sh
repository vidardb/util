#!/bin/sh

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

_install_pg() { 
    ### INSTALL pg11
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

    RELEASE=$(lsb_release -cs)
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}"-pgdg main | sudo tee  /etc/apt/sources.list.d/pgdg.list    
    cat /etc/apt/sources.list.d/pgdg.list
    
    sudo apt update
    sudo apt -y install postgresql-11
    sudo apt -y install postgresql-plpython-11
    sudo apt -y install autoconf
    
    sudo ss -tunelp | grep 5432
    
    sudo sed -i 's/^#listen_addresses/listen_addresses/g' /etc/postgresql/11/main/postgresql.conf
    sudo sed -i "s/^listen_addresses =.*/listen_addresses = '*'/g" /etc/postgresql/11/main/postgresql.conf
    sudo systemctl restart postgresql
}

_install_madlib() {
    ### INSTALL madlib
    output=apache-madlib-1.16-bin-Linux.deb
    wget https://dist.apache.org/repos/dist/release/madlib/1.16/apache-madlib-1.16-bin-Linux.deb -O "${output}"
    sudo dpkg -i "${output}"
    
    ### INSTALL madlib module
    
    #    Name     |     Owner     | Encoding |   Collate   |    Ctype    |   Access privileges
    #-------------+---------------+----------+-------------+-------------+-----------------------
    # payment_dev | rails_payment | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    # postgres    | postgres      | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    # template0   | postgres      | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
    #             |               |          |             |             | postgres=CTc/postgres
    # template1   | postgres      | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
    #             |               |          |             |             | postgres=CTc/postgres
    # testdb      | postgres      | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    
    #sudo su - postgres
    #psql -c "CREATE USER rails_payment WITH PASSWORD 'rails_payment';"
    #psql -c "CREATE DATABASE payment_dev OWNER rails_payment;"
    #psql -c "ALTER USER rails_payment WITH SUPERUSER;"
    #
    #export PGUSER=rails_payment
    #export PGPASSWORD=rails_payment
    #export PGPORT=5432
    #export PGHOST=127.0.0.1
    #export PGDATABASE=payment_dev
    #
    #/usr/local/madlib/bin/madpack -p postgres install
    
    ### wiki check
    # psql -h localhost -p 5432 -U rails_payment payment_dev; 
    
    sudo su - postgres -c "{
        psql -c \"CREATE USER postgres WITH PASSWORD 'postgres';\"
        psql -c \"CREATE DATABASE madlib OWNER madlib;\"
        #psql -c \"ALTER USER rails_payment WITH SUPERUSER;\"
        psql -c \"ALTER USER postgres WITH SUPERUSER;\"
}"

   export PGUSER=postgres
   export PGPASSWORD=postgres
   export PGPORT=5432
   export PGHOST=127.0.0.1
   export PGDATABASE=madlib
   
   /usr/local/madlib/bin/madpack -p postgres install
}
# 
# https://cwiki.apache.org/confluence/display/MADLIB/Quick+Start+Guide+for+Users

## usage
_usage() {
    cat << USAGE
Usage: bash ${MYNAME} install_pg|install_madlib

Action:
    install_pg               Install pg11.
    install_madlib           Install madlib for pg11.
USAGE

    exit 1
}

## main
action=$1
case $action in
    ## opt
    "install_pg" )
        _install_pg
        ;;
    "install_madlib" )
        _install_madlib
        ;;
    *)
        _usage
        ;;
esac
