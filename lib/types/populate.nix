{ lib }: rec {

  source = lib.types.submodule ({ config, ... }: {
    options = {
      type = let
        known-types = lib.attrNames source-types;
        type-candidates = lib.filter (k: config.${k} != null) known-types;
      in lib.mkOption {
        default = if lib.length type-candidates == 1
                    then lib.head type-candidates
                    else throw "cannot determine type";
        type = lib.types.enum known-types;
      };
      derivation = lib.mkOption {
        apply = x:
          if lib.types.str.check x
            then { text = x; }
            else x;
        default = null;
        type = lib.types.nullOr (lib.types.either lib.types.str source-types.derivation);
      };
      file = lib.mkOption {
        apply = x:
          if lib.types.absolute-pathname.check x || lib.types.package.check x
            then { path = x; }
            else x;
        default = null;
        type = lib.types.nullOr (lib.types.oneOf [
          lib.types.absolute-pathname
          lib.types.package
          source-types.file
        ]);
      };
      git = lib.mkOption {
        default = null;
        type = lib.types.nullOr source-types.git;
      };
      pass = lib.mkOption {
        default = null;
        type = lib.types.nullOr source-types.pass;
      };
      pipe = lib.mkOption {
        apply = x:
          if lib.types.absolute-pathname.check x
            then { command = x; }
            else x;
        default = null;
        type = lib.types.nullOr (lib.types.either lib.types.absolute-pathname source-types.pipe);
      };
      symlink = lib.mkOption {
        apply = x:
          if lib.types.pathname.check x
            then { target = x; }
            else x;
        default = null;
        type = lib.types.nullOr (lib.types.either lib.types.pathname source-types.symlink);
      };
    };
  });

  filter = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum ["include" "exclude"];
        default = "exclude";
      };
      pattern = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  source-types = {
    derivation = lib.types.submodule {
      options = {
        text = lib.mkOption {
          type = lib.types.str;
        };
      };
    };
    file = lib.types.submodule {
      options = {
        path = lib.mkOption {
          type = lib.types.absolute-pathname;
        };
        useChecksum = lib.mkOption {
          default = false;
          type = lib.types.bool;
        };
        exclude = lib.mkOption {
          apply = x:
            if x != [] then
              lib.warn
                "file.*.exclude is deprecated in favor of file.*.filters"
                x
            else
              x;
          description = ''
            DEPRECATED, use `filters`.
          '';
          type = lib.types.listOf lib.types.str;
          default = [];
          example = [".git"];
        };
        filters = lib.mkOption {
          type = lib.types.listOf filter;
          default = [];
          example = [
            {
              type = "include";
              pattern = "*.nix";
            }
            {
              type = "include";
              pattern = "*/";
            }
            {
              type = "exclude";
              pattern = "*";
            }
          ];
        };
        deleteExcluded = lib.mkOption {
          default = true;
          type = lib.types.bool;
        };
      };
    };
    git = lib.types.submodule {
      options = {
        clean = {
          exclude = lib.mkOption {
            default = [];
            type = lib.types.listOf lib.types.str;
          };
        };
        fetchAlways = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        ref = lib.mkOption {
          type = lib.types.str; # TODO lib.types.git.ref
        };
        url = lib.mkOption {
          type = lib.types.str; # TODO lib.types.git.url
        };
        shallow = lib.mkOption {
          default = false;
          type = lib.types.bool;
        };
      };
    };
    pass = lib.types.submodule {
      options = {
        dir = lib.mkOption {
          type = lib.types.absolute-pathname;
        };
        name = lib.mkOption {
          type = lib.types.pathname; # TODO relative-pathname
        };
      };
    };
    pipe = lib.types.submodule {
      options = {
        command = lib.mkOption {
          type = lib.types.absolute-pathname;
        };
      };
    };
    symlink = lib.types.submodule {
      options = {
        target = lib.mkOption {
          type = lib.types.pathname; # TODO relative-pathname
        };
      };
    };
  };

}
