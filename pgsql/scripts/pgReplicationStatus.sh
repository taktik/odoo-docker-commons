#!/bin/bash
source /root/.profile

psql -X -t --quiet --single-transaction --no-align -c "select coalesce(round(extract(epoch from (now() - pg_last_xact_replay_timestamp()))),0) AS time_lag, pg_last_xact_replay_timestamp() AS last_replay_timestamp, pg_last_xlog_receive_location() as last_receive_location, pg_last_xlog_replay_location() as last_replay_location;" | while IFS='|' read time_lag last_replay_timestamp last_receive_location last_replay_location; do
    echo "`date -u +'%Y-%m-%dT%H:%M:%SZ'` '$time_lag' '$last_replay_timestamp' '$last_receive_location' '$last_replay_location'"
done
