#!/bin/bash

HOSTNAME=`hostname`
IFS=" "
IPS=`hostname -i`
echo "HOSTNAME==>$HOSTNAME";
echo "IPS==>$IPS";
read -r -a IP_ADDRESSES <<< "$IPS"

ZK_CONF_DIR="/kafka/config"
ZK_CONF_FILE="zookeeper.properties"
MYID_REGEX="\\.([0-9]{1,3})="

function extractMyId {
  if [[ $1 =~ $MYID_REGEX ]]
  then
    echo "${BASH_REMATCH[1]}"
  else
    echo "NaN"
  fi
}

while read line
do
  if [[ $line = dataDir=* ]];
  then
    IFS="="
    read -r key ZK_DATADIR <<< "$line"
    [[ -d "$ZK_DATADIR" ]] || mkdir -p "$ZK_DATADIR"
  fi
  if [[ $line = dynamicConfigFile=* ]];
  then
    IFS="="
    read -r key ZK_DYNAMIC_CONFIG_FILE <<< "$line"
  fi
done < "$ZK_CONF_DIR/$ZK_CONF_FILE"

#echo "ZK_DATADIR:$ZK_DATADIR";
#echo "ZK_DYNAMIC_CONFIG_FILE:$ZK_DYNAMIC_CONFIG_FILE";
#echo "HOSTNAME:$HOSTNAME"
#echo "IPS:$IPS"

if [ ! -f "$ZK_DATADIR/myid" ]; then
  while read line
  do
    echo "READING CONFIGLINE: $line"
    if [[ $line == *"$HOSTNAME"* ]];
    then
      MYID=`extractMyId "$line"`;
      echo $MYID >> "$ZK_DATADIR/myid"
      echo "Writing myid $MYID to $ZK_DATADIR/myid"
      break;
    else
	    #for ip in `ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
	    for ip in ${IP_ADDRESSES[@]}
	    do
	      if [[ $line == *"$ip"* ]];
        then
	        MYID=`extractMyId "$line"`;
          echo $MYID >> "$ZK_DATADIR/myid"
          echo "Writing myid $MYID to $ZK_DATADIR/myid"
          break;
        fi
	    done
    fi
  done < "$ZK_DYNAMIC_CONFIG_FILE"
fi
exit $MYID

