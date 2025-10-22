{
  description = "Elixir Phoenix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        optional = pkgs.lib.optional;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "lumen";
          buildInputs =
            with pkgs;
            [
              elixir_1_19
              elixir-ls
              esbuild
              postgresql
              rebar3
              tailwindcss_4
              tailwindcss-language-server
              watchman

              (writeShellScriptBin "pg-setup" ''
                createuser -d postgres
              '')

              (writeShellScriptBin "pg-start" ''
                if [ ! -d $PGDIR ]; then
                  mkdir -p $PGDIR
                fi

                if [ ! -d $PGDATA ]; then
                  echo "Initializing Postgres DB..."
                  initdb $PGDATA --auth=trust >/dev/null
                fi

                if [ ! -S $PGHOST/.s.PGSQL.5432 ]; then
                  echo "Starting Postgres DB..."
                  pg_ctl start -D $PGDATA -l $PGLOG -o "-h ''\'''\' -k $PGHOST"
                else
                  echo "Postgres DB already running..."
                fi
              '')

              (writeShellScriptBin "pg-stop" ''
                pg_ctl stop -D $PGDATA
              '')

              (writeShellScriptBin "install-phx" ''
                mix archive.install hex phx_new
              '')
            ]
            ++ optional pkgs.stdenv.isLinux pkgs.libnotify
            ++ optional pkgs.stdenv.isLinux pkgs.inotify-tools;

          shellHook = ''
            export SHELL_DIR=$PWD/.nixenv

            if ! test -d $SHELL_DIR; then
              mkdir -p $SHELL_DIR
            fi

            export MIX_HOME=$SHELL_DIR/mix
            export HEX_HOME=$SHELL_DIR/hex
            export ERL_AFLAGS="-kernel shell_history enabled"

            export PATH="$MIX_HOME/bin:$HEX_HOME/bin:$MIX_HOME/escripts:$PATH"

            set -e
            export PGDIR=$SHELL_DIR/pg
            export PGHOST=$PGDIR
            export PGDATA=$PGDIR/data
            export PGLOG=$PGDIR/log
            export DATABASE_URL="postgresql:///postgres?host=$PGDIR"

            export TAILWINDCSS_PATH="${pkgs.lib.getExe pkgs.tailwindcss_4}"
          '';
        };
      }
    );
}
