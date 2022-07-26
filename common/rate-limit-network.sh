#!/bin/bash

# Limit all incoming and outgoing network
tc qdisc add dev eth0 handle 1: ingress
tc filter add dev eth0 parent 1: protocol ip prio 50 u32 match ip src 0.0.0.0/0 police rate $NETWORK_RATE_LIMIT burst 10k drop flowid :1
tc qdisc add dev eth0 root tbf rate $NETWORK_RATE_LIMIT latency 25ms burst 10k

