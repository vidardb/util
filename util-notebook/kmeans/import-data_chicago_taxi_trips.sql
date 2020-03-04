--
-- exec sql
-- psql -U postgres -W -f import-data_chicago_taxi_trips.sql

-- create user test_user, and set it's password
-- create user postgres with password 'postgres';

-- create database, and set it's owner
create database chicago_taxi_trips with owner postgres;

-- connect to new database
\c chicago_taxi_trips postgres;

drop table if exists chicago_taxi_trips;

create table chicago_taxi_trips
(
    taxi_id int default 0 not null,
    trip_start_timestamp timestamp not null,
    trip_end_timestamp timestamp not null,
    trip_seconds int default 0 not null,
    trip_miles decimal(10, 2),
    pickup_census_tract int default 0,
    dropoff_census_tract int default 0,
    pickup_community_area int default 0,
    dropoff_community_area int default 0,
    fare decimal(10, 2),
    tips decimal(10, 2),
    tolls decimal(10, 2),
    extras decimal(10, 2),
    trip_total decimal(10, 2),
    payment_type varchar(50) not null default '',
    company varchar(50)  default '',
    pickup_latitude int default 0,
    pickup_longitude int default 0,
    dropoff_latitude int default 0,
    dropoff_longitude int default 0
);

\copy chicago_taxi_trips from 'chicago_taxi_trips.csv' csv header;

