#!/bin/bash

psql -U postgres -c "select *, pg_xlog_location_diff(pg_stat_replication.sent_location, pg_stat_replication.replay_location) AS byte_lag from pg_stat_replication;"
