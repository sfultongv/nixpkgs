#!/bin/bash
source $stdenv/setup


# start installation
mkdir $out
cp $src $out
cp $license $out/license.properties
$java/bin/java -server -XX:MaxPermSize=266M -Xmx1124m -jar $out/$jarname -r $runmode,nosamplecontent &

# wait until installation complete
status=500
while [ $status != 200 ] && [ $status != 401 ]
do
  echo "Waiting 2 minutes to check if started"
  sleep 120
  status=$($curl/bin/curl -o /dev/null -w '%{http_code}' localhost:4502/$checkpath 2> /dev/null)
  echo "AEM response: $status"
done


# shut down AEM
#$java/bin/java -jar `ls $out/crx-quickstart/app/*.jar | head -1` "stop -c $out/crx-quickstart"
#STOP_CODE=$?
STOP_CODE="9"
if [ "${STOP_CODE}" == "0" ]; then
	echo "Application not running"
else
	echo "Stop command returned ${STOP_CODE}. Trying to kill the process..."
	if [ -f $out/crx-quickstart/conf/cq.pid ]; then
		PID=$(cat $out/crx-quickstart/conf/cq.pid 2>/dev/null)
	else
		PID=""
	fi
	echo "acquired pid"
	if [ "$PID" ]; then
		rm -f $out/crx-quickstart/conf/cq.pid
		echo "removed pid file"
		if ps -p $PID > /dev/null 2>&1; then
			echo "killing process..."
			kill $PID
			STOP_CODE=$?
			echo "process ${PID} was killed"
		else
			echo "process ${PID} not running"
		fi
	else
		echo "cq.pid not found"
	fi
fi

# patch startup script
#sed -i "1s/.*/#!\/bin\/sh/" $out/crx-quickstart/bin/start

