{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "2.3";
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          wego_custom = pkgs.buildGoModule {
            pname = "wego";
            inherit version;
            src = ./.;
            vendorHash = "sha256-jn8bIl5nAJlHB1Sdth95KhIiW4OQgD10B+Dk4mh756Q=";
          };
        });
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ go gopls gotools go-tools ];
          };
        });
      defaultPackage = forAllSystems (system: self.packages.${system}.wego_custom);
    };
}
