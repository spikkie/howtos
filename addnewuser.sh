#!/bin/env bash

sudo su
useradd -c "Mary Phillips" -m  -s "/bin/bash" mphillips
passwd mphillips
useradd richard
cat /etc/passwd
passwd richard
usermod -c "Richard Layton" richard
groupadd accounting
usermod -G accounting richard
groups richard

