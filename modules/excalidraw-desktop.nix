{ fetchurl, pkgs }:
let
	pname = "excalidraw";
	version = "0.2.0";
	binname = "excalidraw-desktop";

	src = fetchurl {
		url = "https://github.com/45Hnri/excalidraw-desktop/releases/download/v${version}/${binname}.AppImage";
		hash = "sha256:0d7484058190dd30f75440471b82c261fe4df36635d600a5e4642fc7ce13d2d4";
	};

	appimageContents = pkgs.appimageTools.extract {inherit pname version src;};
in
	pkgs.appimageTools.wrapType2 {
		inherit pname version src;
		extraInstallCommands = ''
      mv $out/bin/excalidraw $out/bin/.excalidraw
      cat <<EOF > $out/bin/excalidraw
      #!${pkgs.runtimeShell}
      if [ -n "\$1" ] && [ -f "\$1" ]; then
        exec $out/bin/.excalidraw "\$(${pkgs.coreutils}/bin/realpath "\$1")"
      else
        exec $out/bin/.excalidraw "\$@"
      fi
      EOF
      chmod +x $out/bin/excalidraw

      install -m 444 -D ${appimageContents}/${binname}.desktop -t $out/share/applications
      mv $out/share/applications/${binname}.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'

      # put the icon in 0x0 for some reason, which does not display correctly
      mkdir -p $out/share/icons/hicolor/512x512
      cp -r ${appimageContents}/usr/share/icons/hicolor/0x0/* \
        $out/share/icons/hicolor/512x512

      # normal procedure
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
	}
