#!/bin/bash

psql -c "select pg_last_xact_replay_timestamp() AS last_replay_timestamp, now() - pg_last_xact_replay_timestamp() AS replication_delay, pg_last_xlog_receive_location(), pg_last_xlog_replay_location();"
