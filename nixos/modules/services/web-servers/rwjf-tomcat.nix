{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.rwjf-tomcat;
  tomcat = pkgs.tomcat7;
  solr = pkgs.solr;
  java = pkgs.oraclejdk7;
  rwjf-solr = pkgs.rwjf_source_solr;
  solr-context = builtins.toFile "solr.xml" 
    ''
      <?xml version="1.0" encoding="utf-8"?>
      <Context crossContext="true">
        <Environment name="solr/home" type="java.lang.String" value="/var/search" override="true"/>
      </Context>

    '';
  server-xml = builtins.toFile "server.xml"
    ''
    <?xml version='1.0' encoding='utf-8'?>
    <Server port="8005" shutdown="SHUTDOWN">
      <Listener className="org.apache.catalina.core.JasperListener" />
      <!-- Prevent memory leaks due to use of particular java/javax APIs-->
      <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
      <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
      <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
      <GlobalNamingResources>
        <Resource name="UserDatabase" auth="Container"
                  type="org.apache.catalina.UserDatabase"
                  description="User database that can be updated and saved"
                  factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
                  pathname="conf/tomcat-users.xml" />
      </GlobalNamingResources>
      <Service name="Catalina">
        <Connector port="8983" protocol="HTTP/1.1"
                   connectionTimeout="20000"
                   URIEncoding="UTF-8"
                   redirectPort="8443" />
        <Engine name="Catalina" defaultHost="localhost">
          <Realm className="org.apache.catalina.realm.LockOutRealm">
            <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
                   resourceName="UserDatabase"/>
          </Realm>
          <Host name="localhost"  appBase="webapps"
                unpackWARs="true" autoDeploy="true">
            <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
                   prefix="localhost_access_log." suffix=".txt"
                   pattern="%h %l %u %t &quot;%r&quot; %s %b" />
          </Host>
        </Engine>
      </Service>
    </Server>
    '';
  setenv = builtins.toFile "setenv.sh"
    ''
     export CATALINA_OPTS="$CATALINA_OPTS -Djava.awt.headless=true -Xmx${cfg.heap} -server -Xmn512m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:NewSize=756m -XX:MaxNewSize=756m -XX:SurvivorRatio=4 -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled"
     export CLASSPATH="$CLASSPATH:/var/search/lib/log/*"

    '';
  makeCore = { coreName, cfgName }: 
    ''
    cp -a ${rwjf-solr}/files/home/cores/main /var/search/cores/${coreName}
    echo -e "name=${coreName}\n" > /var/search/cores/${coreName}/core.properties
    cp ${rwjf-solr}/files/solrconfig.xml.${cfgName} /var/search/cores/${coreName}/conf/solrconfig.xml
    '';
  authorCores = concatMapStrings makeCore [ { coreName = "main"; cfgName = "author"; } { coreName = "reporting"; cfgName = "reporting"; } ];
  publishCores = concatMapStrings makeCore [ { coreName = "main"; cfgName = "publish"; } ];

in

{
  
  ##### interface
  options = {
    services.rwjf-tomcat = {

      enable = mkOption {
        default = false;
        description = "Whether to enable Apache Tomcat (for solr)";
      };

      heap = mkOption {
        default = "2G";
        description = "amount of heap space to give Tomcat";
      };
    };
  };


  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.rwjf-tomcat = {
      description = "Tomcat running Solr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = 
        ''
        if [ ! -d /var/tomcat ]; then
          # create tomcat directory, if it doesn't exist
          mkdir -p /var/tomcat/conf/Catalina/localhost
          # copy configs from original tomcat install
          cp -a ${tomcat}/* /var/tomcat
          # use our custom server.xml
          cp ${server-xml} /var/tomcat/conf/server.xml
          # deploy war file
          cp ${solr}/lib/solr.war /var/tomcat/webapps/solr-author.war
          # copy war configuration
          cp ${solr-context} /var/tomcat/conf/Catalina/localhost/solr-author.xml
          # copy file to set environment variables
          cp ${setenv} /var/tomcat/bin/setenv.sh
          chmod u+x /var/tomcat/bin/setenv.sh
        fi

        
        if [ ! -d /var/search ]; then
          # create solr directory, if it doesn't exist
          mkdir -p /var/search/cores
          # copy data from rwjf source
          cp -a ${rwjf-solr}/files/lib /var/search/lib
          cp ${rwjf-solr}/files/home/solr.xml /var/search
          cp ${rwjf-solr}/files/home/zoo.cfg /var/search
          ${authorCores}
          # make sure solr has write access to core directories 
          chmod -R u+w /var/search/cores

        fi 
        '';
      environment = {
        JAVA_HOME = java;
      };
      serviceConfig = {
        ExecStart = "/var/tomcat/bin/startup.sh";
        Type = "forking";
      };
    };
  };
}
