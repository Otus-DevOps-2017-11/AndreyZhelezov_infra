#!/bin/bash

git clone https://github.com/Otus-DevOps-2017-11/reddit.git
su appuser -c "cd reddit && bundle install"

cp /tmp/puma.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable puma.service
