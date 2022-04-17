#!/usr/bin/env bash

#To use key auth from your PC you have to generate a key pair (local user does not have to be the same as remote user)
ssh-keygen

#After that, copy the public key to the home directory of the user@server you want to connect to
ssh-copy-id user100@192.168.1.234

#When using ssh you can use -o  StrictHostKeyChecking=No to not get the trust question

#Example of running a command without interactive logon
ssh user100@192.168.1.235 hostname
