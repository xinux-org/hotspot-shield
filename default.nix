{pkgs ? import <nixpkgs> {}, ...}: let
  lib = pkgs.lib;
in
  pkgs.stdenv.mkDerivation rec {
    pname = "hotspotshield";
    version = "1.0.7";

    src = pkgs.fetchurl {
      # https://repo.hotspotshield.com/deb/rel/all/pool/main/h/hotspotshield/hotspotshield_1.0.7_amd64.deb
      url = "https://repo.hotspotshield.com/deb/rel/all/pool/main/h/${pname}/${pname}_${version}_amd64.deb";
      hash = "sha256-blmaelyHGbRVx1xLOMeH4pylue3VcdYZfDFO6s7+cnw=";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      glibc
      patchelf
      autoPatchelfHook
    ];

    unpackPhase = ''
      # Unpack .deb
      mkdir -p $out $out/bin
      mkdir -p $out $out/lib
      dpkg -x $src $out

      # Follow nix way
      cp -r $out/usr/lib/* $out/lib/
      cp -r $out/usr/bin/* $out/bin/

      # Deleting garbages
      rm -rf $out/usr
      rm -rf $out/etc
    '';

    buildInputs = with pkgs; [
      libgcc
      dbus.lib
      libnl
      stdenv.cc.cc.lib
      curl
      procps
      dialog
      util-linux
      libxcrypt-legacy
      openssl
    ];

    installPhase = ''
      echo $unpackPhase
      runHook preInstall
      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://www.hotspotshield.com";
      description = "Hotspot Shield VPN client for NixOS.";
      licencse = lib.licenses.unfree;
      # mainProgram = "hotspotshield";
      platforms = with platforms; linux;
      maintainers = [
        lib.maintainers.orzklv
      ];
    };
  }
