#!/usr/bin/expect -f

set timeout 100

spawn ./zanata_exec.sh

expect "Are you sure (y/n)?"

send "y\r"

interact
