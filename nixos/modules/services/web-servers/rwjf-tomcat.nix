{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.rwjf-tomcat;
  tomcat = pkgs.tomcat7;
  solr = pkgs.solr;
  java = pkgs.oraclejdk7;
  rwjf-solr = pkgs.rwjf_source_solr;
  schema = builtins.toFile "schema.xml" cfg.schema;
  makeSolrContext = serverType: builtins.toFile "solr.xml"
    ''
      <?xml version="1.0" encoding="utf-8"?>
      <Context crossContext="true">
        <Environment name="solr/home" type="java.lang.String" value="/var/search/${serverType}" override="true"/>
      </Context>

    '';
  deployWar = type:
    ''
    cp ${solr}/lib/solr.war /var/tomcat/webapps/solr-${type}.war
    cp ${makeSolrContext type} /var/tomcat/conf/Catalina/localhost/solr-${type}.xml
    '';
  deployedWars = concatMapStrings deployWar (builtins.attrNames cfg.wars);
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
  makeCore = { typeName, coreName, solrconfig }: 
    let coreDir = "/var/search/${typeName}/cores/${coreName}";
    in
    ''
    mkdir -p ${coreDir}/conf
    cp -a ${rwjf-solr}/home/cores/main/* ${coreDir}
    echo -e "name=${coreName}\n" > ${coreDir}/core.properties
    cp ${builtins.toFile "solrconfig.xml" solrconfig} ${coreDir}/conf/solrconfig.xml
    # copy over schema
    cp ${schema} ${coreDir}/conf
    '';
  deployCores = typeName: coreSet: 
    let cores = concatStrings
            (mapAttrsToList (coreName: solrconfig: makeCore { inherit typeName coreName solrconfig; }) coreSet);
    in 
    ''
      if [ ! -d /var/search/${typeName} ]; then
         # copy data from rwjf source
         mkdir -p /var/search/${typeName}
         cp -a ${rwjf-solr}/lib /var/search/${typeName}/lib
         cp ${rwjf-solr}/home/solr.xml /var/search/${typeName}
         cp ${rwjf-solr}/home/zoo.cfg /var/search/${typeName}
         ${cores}
      fi 
    '';
in

{
  
  ##### interface
  options = {
    services.rwjf-tomcat = {

      wars = mkOption {
        default = {};
        description = "a property list of war names and their cores with associated configurations";
      };

      heap = mkOption {
        default = "2G";
        description = "amount of heap space to give Tomcat";
      };
      schema = mkOption {
        default = "";
        description = "The schema.xml for all solr instances";
      };
    };
  };


  ###### implementation
  config = mkIf (cfg.wars != {}) {
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

          # deploy enabled war files
          ${deployedWars}

          # copy file to set environment variables
          cp ${setenv} /var/tomcat/bin/setenv.sh
          chmod u+x /var/tomcat/bin/setenv.sh
        fi

        # deploy cores for each solr type (author/publish)
        ${
          concatStrings (mapAttrsToList deployCores cfg.wars)
        }
        # make sure solr has write access to core directories 
        chmod -R u+w /var/search
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
