#!/bin/bash -x

# This script will use vegeta to load test a Vault
# server, generating a configurable number of 
# KV entries and reporting on the read and write
# latency.

# Assumes VAULT_ADDR is already set in env and
# that you're vault token is available in your
# home directory 

# Assumes vegeta is already installed
# https://github.com/tsenart/vegeta

# Start and stop KV indexes
seq_start=1
seq_stop=200

# how many requests per second
write_rate=500
read_rate=500

# how long to run for
write_duration=10s
read_duration=10s

# initial worker count
workers=20

# get the token
token=`cat ~/.vault-token`

# Write POST URL list
posturls=posturls.lst
>$posturls
for x in `seq -w ${seq_start} ${seq_stop}`; do
    echo "POST ${VAULT_ADDR}/v1/secret/data/k${x}" >>$posturls
    echo "@write-body.json" >>$posturls
    echo "" >>$posturls
done


# Write JSON body for KV writes
cat > write-body.json <<EOF
{
  "data": {
      "foo": "bar",
      "zip": "zap"
    }
}
EOF

vegeta attack \
    -header="X-Vault-Token: ${token}" \
    -targets=${posturls} \
    -duration=${write_duration} \
    -workers=${workers} \
    -rate=${write_rate} \
    >post-results.bin 


# Write GET URL list
geturls=geturls.lst
>$geturls
for x in `seq -w ${seq_start} ${seq_stop}`; do
    echo "GET ${VAULT_ADDR}/v1/secret/data/k${x}" >>$geturls
    echo "" >>$geturls
done

vegeta attack \
    -header="X-Vault-Token: ${token}" \
    -targets=${geturls} \
    -duration=${read_duration} \
    -workers=${workers} \
    -rate=${read_rate} \
    >read-results.bin 

vegeta plot < post-results.bin > ~/tmp/post-results.html
vegeta report < post-results.bin > post-report.txt
vegeta plot < read-results.bin > ~/tmp/read-results.html
vegeta report < read-results.bin > read-report.txt
