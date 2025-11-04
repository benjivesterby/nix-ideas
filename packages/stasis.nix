{
  pkgs,
  inputs,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  pname = "stasis";
  version = "0.4.12";

  src = inputs.stasis;
  cargoHash = "sha256-M5L6kcx/FY+cusYhVSDoKCyuH0LpaPXzBo3wJZsLQak=";

  buildInputs = [
    pkgs.dbus
    pkgs.udev
    pkgs.libinput
  ];

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  dbus = pkgs.dbus;
  doCheck = false;

  meta.platforms = pkgs.lib.platforms.linux;
}
