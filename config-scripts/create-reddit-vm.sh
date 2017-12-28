#!/bin/bash

# Определение переменных
GCP_PROJECT_ID="infra-189117"
TIMESTAMP=$(date +%s)

# Создание инстанса с идентификатором, включающим временной штамп, для уникальности имени инстанса
gcloud compute \
--project $GCP_PROJECT_ID instances create "instance-$TIMESTAMP" \
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
--image-project $GCP_PROJECT_ID \
--boot-disk-device-name "instance-$TIMESTAMP"
