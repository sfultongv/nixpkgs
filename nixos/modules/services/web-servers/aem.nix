{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aem;
  aem = pkgs.aem56;
  java = pkgs.oraclejdk7;
  crx = "${cfg.directory}/crx-quickstart";
in

{ 
  #### interface
  options = {
    services.aem = {

      enable = mkOption {
        default = false;
        description = "Whether to enable Adobe Experience Manager";
      };

      directory = mkOption {
        default = "/var/aem";
        description = "Directory where AEM should be deployed";
      };

    };
  };

  #### implementation
  config = mkIf config.services.aem.enable {

    users.extraGroups = singleton {
      name = "aem";
      gid = config.ids.gids.aem;
    };

    users.extraUsers = singleton {
      name = "aem";
      uid = config.ids.uids.aem;
    };

    systemd.services.aem = {
      description = "Adobe Experience Manager";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart =
        ''
         # create install directory, if it doesn't already exist
         mkdir -p ${cfg.directory}

         # copy installed AEM files to deploy directory
         if [ ! -d ${cfg.directory}/crx-quickstart ]; then
           cp -a ${aem}/crx-quickstart ${cfg.directory}

           # create start/stop scripts
           CQ_JVM_OPTS="-server \
             -Xmx2g -XX:PermSize=256m -XX:MaxPermSize=288m \
             -Djava.awt.headless=true \
             -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC \
             -Dorg.apache.jackrabbit.core.state.validatehierarchy=true \
             -Djava.net.preferIPv4Stack=true \
             -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/cq/dumps"
           START_OPTS="-c ${crx} -i launchpad -p 4502 -Dsling.run.modes=author"
           cat > ${crx}/bin/start << EOF
#!${pkgs.bash}/bin/bash
${java}/bin/java $CQ_JVM_OPTS -jar ${crx}/app/cq-quickstart-5.6.1-standalone.jar $START_OPTS & echo $! > ${crx}/conf/cq.pid
EOF

         fi
         if [ ! -e ${cfg.directory}/license.properties ]; then
           cp ${aem}/license.properties ${cfg.directory}
         fi

         # make sure all files have correct ownership
         chown -R aem:aem ${cfg.directory}
        '';
         
      serviceConfig = {
        ExecStart = "${crx}/bin/start";
        Type = "forking";
      };
    };
  };
}
