#!/bin/sh

logfile=/tmp/user_data.log
echo START `date '+%Y-%m-%d %H:%M:%S'` >> $logfile

#
# Export user data, which is defined with the "UserData" attribute
# in the template
#
%EXPORT_USER_DATA%

#
# Add your customization script here
#

#
# Source LSF enviornment at the VM host
#
LSF_TOP=/opt/lsf_101_GPcc
LSF_CONF_FILE=$LSF_TOP/conf/lsf.conf
. $LSF_TOP/conf/profile.lsf
env >> $logfile

#
# Support rc_account resource to enable RC_ACCOUNT policy
# Add additional local resources if needed
#
if [ -n "${rc_account}" ]; then
sed -i "s/\(LSF_LOCAL_RESOURCES=.*\)\"/\1 [resourcemap ${rc_account}*rc_account]\"/" $LSF_CONF_FILE
echo "update LSF_LOCAL_RESOURCES lsf.conf successfully, add [resourcemap ${rc_account}*rc_account]" >> $logfile
fi

#
# Run lsreghost command to register the host to LSF master if no DNS update
#
echo "lsfmaster.softlayer.com" > $LSF_ENVDIR/hostregsetup
lsreghost -s $LSF_ENVDIR/hostregsetup

useradd lsfadmin

#
# Start LSF Daemons
#
$LSF_SERVERDIR/lsf_daemons start

echo END AT `date '+%Y-%m-%d %H:%M:%S'` >> $logfile
