{
  description = "Gowin EDA Linux packaged for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          gowin = pkgs.callPackage ./default.nix {
            gowinRoot = self;
          };
        in
        {
          default = gowin;
          gowin = gowin;
        }
      );

      apps = forAllSystems (system: {
        default = self.apps.${system}.gowin;
        gowin = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/gowin-fhs";
          meta.description = "Run the Gowin IDE";
        };
      });
    };
}
