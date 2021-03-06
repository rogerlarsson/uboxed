#!/bin/bash

#RUN_IN_CONTAINER cernbox

set -o errexit # bail out on all errors immediately
set -x

export EOS_MGM_URL=root://$EOS_MGM_ALIAS

dd if=/dev/zero of=/tmp/largefile256.dat bs=1024 count=250
dd if=/dev/zero of=/tmp/largefile512.dat bs=1024 count=500
dd if=/dev/zero of=/tmp/largefile1024.dat bs=1024 count=1000
dd if=/dev/zero of=/tmp/largefile10240.dat bs=1024 count=10000


FILES="/etc/passwd /tmp/largefile256.dat /tmp/largefile512.dat /tmp/largefile1024.dat /tmp/largefile10240.dat"

# If the home folder of the user does not exist, create it!
if ! eos ls -ld /eos/docker/user/u/user0/ ; then
    sh /var/www/html/cernbox/cernbox_scripts/homedirscript.sh ${EOS_MGM_URL} ${EOS_PREFIX} ${EOS_RECYCLEDIR} user0
fi

# If the autotest folder is already there, remove it!
if eos ls -ld /eos/docker/user/u/user0/autotest; then 
    eos -r user0 1000 rm -r /eos/docker/user/u/user0/autotest
fi

# Create the autotest folder
eos -r user0 1000 mkdir -p /eos/docker/user/u/user0/autotest

# Run tests with files
for ff in $FILES; do

    f=`basename $ff`

    # upload
    eos -r user0 1000 cp $ff /eos/docker/user/u/user0/autotest/$f || exit 1
    
    # overwrite file
    eos -r user0 1000 cp $ff /eos/docker/user/u/user0/autotest/$f || exit 1
    
    # download
    rm -f /tmp/$f
    eos -r user0 1000 cp /eos/docker/user/u/user0/autotest/$f /tmp/$f || exit 1
done


# test expected failures

#curl -s -f -k -u user0:test1 --upload-file /etc/passwd ${CERNBOXURL}/home/passwd && echo "ERROR: PUT request should fail (wrong password) but succeeded" && exit 1

#curl -s -f -k -u user0:test0 --upload-file /etc/passwd ${CERNBOXURL}/wronghome/passwd && echo "ERROR: PUT request should fail (wrong URI) but succeeded" && exit 1

#curl -s -f -k -u user0:test0 ${CERNBOXURL}/home/passwd_does_not_exist_1234 > /dev/null && echo "ERROR: GET request should fail (no file on the server) but succeeded " && exit 1

exit 0
