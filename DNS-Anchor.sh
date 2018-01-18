#!/bin/bash
 
###########################################
# Do you ever hate having a dynamic IP address?  Do you hate GoDaddy DNS but are stuck with them for some reason?
# This is a simple DDNS script to update records hosted on GoDaddy's DNS. Just schedule it in crontab.
# If you are using the georgegeorgulasiv/godaddy-dns-anchor Docker image, by default cron runs the anchor every 5 minutes.
# You can even make it do stuff (like automation-y things) on the anchor's attempt to update succeeding or failing.
# MAINTAINER georgegeorgulas@gmail.com
###########################################
 
# Begin settings

Key=$GODADDY_API_KEY
Secret=$GODADDY_API_SECRET

###Example Configuration
# Domain
Domain=$DOMAIN
# Record type
Type=A
# Record name
Name=$HOST

CachedIP=/tmp/current_ip

# URL to check public IP, must contain only a single plain text IP.
CheckURL=http://api.ipify.org
 
# Optional scripts/programs/commands to execute on successful update. Leave blank to disable.
SuccessExec='/bin/echo "$(date): My public IP changed to ${PublicIP}!">>../dns-anchor.log'
 
# Optional scripts/programs/commands to execute on update failure. Leave blank to disable.
FailExec='/bin/echo "$(date): Error!  DNS not updated!">>'
# End settings


Curl=$(which curl 2>/dev/null)
[ "${Curl}" = "" ] &&
echo "Error: Unable to find 'curl CLI'." && exit 1
[ -z "${Key}" ] || [ -z "${Secret}" ] &&
echo "Error: Requires API 'Key/Secret' value." && exit 1
[ -z "${Domain}" ] &&
echo "Error: Requires 'Domain' value." && exit 1
[ -z "${Type}" ] && Type=A
[ -z "${Name}" ] && Name=@
[ -z "${TTL}" ] && TTL=600
[ "${TTL}" -lt 600 ] && TTL=600
echo -n>>${CachedIP} 2>/dev/null
[ $? -ne 0 ] && echo "Error: Can't write to ${CachedIP}." && exit 1
[ -z "${CheckURL}" ] && CheckURL=http://api.ipify.org
echo -n "Checking current 'Public IP' from '${CheckURL}'..."
PublicIP=$(${Curl} -kLs ${CheckURL})
if [ $? -eq 0 ] && [[ "${PublicIP}" =~ [0-9]{1,3}\.[0-9]{1,3} ]];then
  echo "${PublicIP}!"
else
  echo "Fail! ${PublicIP}"
  eval ${FailedExec}
  exit 1
fi
if [ "$(cat ${CachedIP} 2>/dev/null)" != "${PublicIP}" ];then
  echo -n "Checking '${Domain}' IP records from 'GoDaddy'..."
  Check=$(${Curl} -kLsH"Authorization: sso-key ${Key}:${Secret}" \
  -H"Content-type: application/json" \
  https://api.godaddy.com/v1/domains/${Domain}/records/${Type}/${Name} \
  2>/dev/null|sed -r 's/.+data":"(.+)","t.+/\1/g' 2>/dev/null)
  if [ $? -eq 0 ] && [ "${Check}" = "${PublicIP}" ];then
    echo -n ${Check}>${CachedIP}
    echo -e "unchanged!\nCurrent 'Public IP' matches 'GoDaddy' records. No update required!">>../dns-anchor.log
  else
    echo -en "changed!\nUpdating '${Domain}'..."
    Update=$(${Curl} -kLsXPUT -H"Authorization: sso-key ${Key}:${Secret}" \
    -H"Content-type: application/json" \
    https://api.godaddy.com/v1/domains/${Domain}/records/${Type}/${Name} \
    -d "{\"data\":\"${PublicIP}\",\"ttl\":${TTL}}" 2>/dev/null)
    if [ $? -eq 0 ] && [ "${Update}" = "{}" ];then
      echo -n ${PublicIP}>${CachedIP}
      echo "Success!"
      eval ${SuccessExec}
    else
      echo "Fail! ${Update}"
      eval ${FailedExec}
      exit 1
    fi  
  fi
else
  echo "Current 'Public IP' matches 'Cached IP' recorded. No update required!"
fi
exit $?
