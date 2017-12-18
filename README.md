Repo init

#######################################################

Infra-2. Домашнее задание #6.

#gcloud command to make an instance

gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --zone=europe-west1-b \
  --metadata startup-script='wget -O - https://gist.githubusercontent.com/AndreyZhelezov/6ba77a556587adecf1702afd0ddd7d17/raw/b5df4246d74c3cbbdfe373989c090e4273a54f7c/startup_script.sh | bash'
