#!/bin/bash
source $stdenv/setup


# start installation
mkdir $out
cp $src $out
cp $license $out/license.properties
$java/bin/java -server -XX:MaxPermSize=266M -Xmx1124m -jar $out/$jarname -r $runmode,nosamplecontent -p $port & echo $! > $TMP/pid

# wait until installation complete
status=500
while [ "$status" != "200" ] && [ "$status" != "401" ]
do
  echo "Waiting 2 minutes to check if started"
  sleep 120
  status=$($curl/bin/curl -sI localhost:$port$checkpath | head -1 | awk '{ print $2 }')
  echo "AEM response: $status"
done

# install osgi bundles
for i in $osgiBundles; do
  echo "installing $i"
  $curl/bin/curl -u admin:admin -F action=install -F bundlestartlevel=20 -F bundlestart=start -F bundlefile=@$i -s localhost:$port/system/console/bundles
done

# shut down AEM
kill -15 `cat $TMP/pid`

# copy over hotfixes, to be installed the next time AEM starts
mkdir -p $out/crx-quickstart/install
for i in $hotfixes; do
  original=$(echo $i | sed 's/[^-]*-//')
  cp $i $out/crx-quickstart/install/$original
done

# make sure sun jars are included in osgi
echo "sling.bootdelegation.com.sun=com.sun.*" >> $out/crx-quickstart/conf/sling.properties

exit 0
