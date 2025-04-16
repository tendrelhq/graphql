{inputs, ...}: {
  imports = [
    inputs.process-compose.flakeModule
  ];
  perSystem = {
    config,
    self',
    pkgs,
    lib,
    ...
  }: {
    devShells.postgres = pkgs.mkShellNoCC {
      name = "tendrelhq/graphql+postgres";
      buildInputs = [
        config.packages.postgresql
        pkgs.perlPackages.TAPParserSourceHandlerpgTAP # pg_prove
        pkgs.python3.pkgs.sqlfmt
        pkgs.sqitchPg
        pkgs.squawk
      ];
    };

    packages = {
      inherit (pkgs) postgresql_14; # beta is on 14.12
      postgresql = pkgs.postgresql_16;
      pgddl = pkgs.stdenv.mkDerivation rec {
        name = "pgddl";
        version = "0.29";
        src = pkgs.fetchFromGitHub {
          owner = "lacanoid";
          repo = name;
          rev = version;
          hash = "sha256-W3G6TGtkj+zXXdGZZR0bmZhsLuFJvuGTlDoo8kL8sf0=";
        };
        buildInputs = with pkgs; [perl config.packages.postgresql];
        postPatch = ''
          patchShebangs .
        '';
        installPhase = ''
          install -D -t $out/share/postgresql/extension *.sql
          install -D -t $out/share/postgresql/extension *.control
        '';
      };
    };

    process-compose.devenv = {
      imports = [
        inputs.services.processComposeModules.default
      ];

      cli.options.no-server = false;

      services.postgres.pg1 = {
        enable = true;
        package = config.packages.postgresql;
        #
        extensions = exts:
          with exts;
          with config.packages; [
            pg_cron
            pgddl
            pgtap
            plpgsql_check
          ];
        initialDatabases = [
          {
            name = "dev";
          }
        ];
        initialScript.after = ''
          create extension ddlx schema pg_catalog;
        '';
        settings = {
          log_statement = "all";
          logging_collector = false;
          shared_preload_libraries = "pg_cron,plpgsql_check";
        };
      };

      services.pgadmin.pga1 = {
        enable = true;
        extraConfig.SERVER_MODE = false; # single user
        initialEmail = "postgres@localhost";
        initialPassword = "postgres";
      };

      settings.processes = {
        pga1 = {
          depends_on.pg1.condition = "process_healthy";
        };
      };
    };
  };
}
