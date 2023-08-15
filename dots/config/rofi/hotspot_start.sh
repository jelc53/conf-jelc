#!/bin/bash
# for some reason, it doesn't use 2.4 from config
nohup create_ap --config /etc/create_ap.conf --freq-band 2.4 > /dev/null 2>&1 &
