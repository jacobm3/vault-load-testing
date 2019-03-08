 for x in `vault kv list secret`; do vault kv metadata delete secret/$x; done
