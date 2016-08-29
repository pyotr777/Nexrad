#!/bin/bash
# Syncronise with Nexrad AWS instance

OPTIONS="-anvP"
if [[ "$1"=="-do" ]]; then
	OPTIONS="-avP"
fi
rsync $OPTIONS --exclude=*/.* --exclude=.* ubuntu@ec2-52-197-17-83.ap-northeast-1.compute.amazonaws.com: .
