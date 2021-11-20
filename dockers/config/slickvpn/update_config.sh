#!/usr/bin/bash

wget -r -l 1 -k -p -H --no-directories --accept='*.ovpn' --domains=slickvpn.com https://www.slickvpn.com/locations/ 
rm *.tmp