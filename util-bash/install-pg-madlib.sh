#!/bin/sh

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

############ install postgres ############
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



############ install madlib ############
## Update following info.
MADLIB_DB=chicago_taxi_trips
PG_USER=postgres
PG_PASSWD=postgres

export PGUSER=${PG_USER}
export PGPASSWORD=${PG_PASSWD}
export PGPORT=5432
export PGHOST=127.0.0.1
export PGDATABASE=${MADLIB_DB}

_install_madlib() {
    ### INSTALL madlib
    output=apache-madlib-1.16-bin-Linux.deb
    wget https://dist.apache.org/repos/dist/release/madlib/1.16/apache-madlib-1.16-bin-Linux.deb -O "${output}"
    sudo dpkg -i "${output}"
 
    sudo su - postgres -c "{
        psql -c \"CREATE USER ${PG_USER} WITH PASSWORD '${PG_PASSWD}';\"
        psql -c \"CREATE DATABASE ${MADLIB_DB} OWNER ${PG_USER};\"
        psql -c \"ALTER USER ${PG_USER} WITH SUPERUSER;\"
}"

   /usr/local/madlib/bin/madpack --platform postgres install
}

# Wiki: https://cwiki.apache.org/confluence/display/MADLIB/Quick+Start+Guide+for+Users

## usage
_usage() {
    cat << USAGE
Usage: bash ${MYNAME} install_pg|install_madlib

Action:
    install_pg               Install pg11.
    install_madlib           Install madlib for pg11.

Attention:
    Update postgres host/database/user/password info in scripts for install madlib.
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

