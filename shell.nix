{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [
      elixir
      yt-dlp
      ffmpeg
      imagemagick
    ];
}
