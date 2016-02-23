#!/bin/sh

# set ENV defaults
MESSAGE_MAX_BYTES=${MESSAGE_MAX_BYTES:-10485760}
MESSAGE_TYPE=${MESSAGE_TYPE:-$KAFKA_TOPIC}
ES_INDEX=${ES_INDEX:-$KAFKA_TOPIC}

# JAVA_HOME is invalid in this base image
unset JAVA_HOME

# check for required ENVs
if [ "x$ES_URL" = "x" ] ; then
  echo "ERROR: ENV variable ES_URL must be declared" >&2
  exit 1
fi
if [ "x$KAFKA_TOPIC" = "x" ] ; then
  echo "ERROR: ENV variable KAFKA_TOPIC must be declared" >&2
  exit 2
fi
if [ "x$ZK_CONNECT_LIST" = "x" ] ; then
  echo "ERROR: ENV variable ZK_CONNECT_LIST must be declared" >&2
  exit 3
fi


# inject ENVs into placeholders
sed -i "s#__ZKCONNECTLIST__#$ZK_CONNECT_LIST#" /logstash/config/logstash.conf
sed -i "s#__MESSAGEMAX__#$MESSAGE_MAX_BYTES#" /logstash/config/logstash.conf
sed -i "s#__MESSAGETYPE__#$MESSAGE_TYPE#" /logstash/config/logstash.conf
sed -i "s#__KAFKATOPIC__#$KAFKA_TOPIC#" /logstash/config/logstash.conf
sed -i "s#__ESINDEX__#$ES_INDEX#" /logstash/config/logstash.conf
sed -i "s#__ESURL__#$ES_URL#" /logstash/config/logstash.conf
sed -i "s#__EXTRAFILTERS__#$EXTRA_FILTERS#" /logstash/config/logstash.conf

# Debug mode?
if [ "x$DEBUG" != "x" ]; then
  echo 'output { stdout { debug => true codec => "rubydebug"} }' >> /logstash/config/logstash.conf

fi

cat /logstash/config/logstash.conf
exec /logstash/bin/logstash --quiet -f /logstash/config/