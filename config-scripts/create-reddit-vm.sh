#!/bin/bash

TIMESTAMP=$(date +%s)

gcloud beta compute \
--project "infra-189117" instances create "instance-$TIMESTAMP" \
--zone "europe-west1-b" \
--machine-type "g1-small" \
--subnet "default" \
--maintenance-policy "MIGRATE" \
--service-account "380934741266-compute@developer.gserviceaccount.com" \
--scopes \
"https://www.googleapis.com/auth/devstorage.read_only",\
"https://www.googleapis.com/auth/logging.write",\
"https://www.googleapis.com/auth/monitoring.write",\
"https://www.googleapis.com/auth/servicecontrol",\
"https://www.googleapis.com/auth/service.management.readonly",\
"https://www.googleapis.com/auth/trace.append" \
--min-cpu-platform "Automatic" \
--tags "puma-server" \
--image-family "reddit-full" \
--image-project "infra-189117" \
--boot-disk-size "12" \
--boot-disk-type "pd-standard" \
--boot-disk-device-name "instance-$TIMESTAMP"
