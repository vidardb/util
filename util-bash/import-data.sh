#!/bin/sh

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

if command -v pgcsv >/dev/null; then
    :
elif command -v pgcsv >/dev/null; then
    echo "please install pgcsv: sudo pip3 install pgcsv"
    exit 1
fi

sudo su - postgres -c "{
    psql -c \"CREATE USER postgres WITH PASSWORD 'postgres';\"
    psql -c \"ALTER USER postgres WITH SUPERUSER;\"
    psql -c \"CREATE DATABASE chicago_taxi_trips OWNER postgres;\"
}"

cd $CURDIR

for i in `ls chicago_taxi_trips_2016_*`; do
    echo $i;
    name=`echo $i | awk -F. '{print $1}' | awk -F/ '{print $NF}'`;
    echo $name;
    pgcsv --db 'postgresql://localhost/chicago_taxi_trips?user=postgres&password=postgres' $name $i;


#    sudo su - postgres -c "{
#        psql -c -U chicago_taxi_trips \"delete from $name where taxi_id is null OR trip_start_timestamp is null OR trip_end_timestamp is null OR trip_seconds is null OR trip_miles is null OR dropoff_census_tract is null OR pickup_community_area is null OR dropoff_community_area is null OR fare is null OR tips is null OR tolls is null OR extras is null OR trip_total is null OR payment_type is null OR company is null OR pickup_latitude is null OR pickup_longitude is null OR dropoff_latitude is null OR dropoff_longitude is null;\"
#}"

done


