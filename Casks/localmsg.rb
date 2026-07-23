cask "localmsg" do
  version "0.2.1"
  sha256 "b150fa67ef1cd9f14b8a55058f4fed5756b0208e1861f855bcd8923cf9bbcf1b"

  url "https://github.com/localmsg-app/localmsg/releases/download/v#{version}/localmsg-macos.zip"
  name "LocalMsg"
  desc "Messagerie sur reseau local (LAN), a la LocalSend mais pour du texte"
  homepage "https://localmsg-app.github.io/localmsg/"

  app "localmsg.app"

  caveats <<~EOS
    localmsg n'est pas signe/notarise par Apple. Au premier lancement, si
    macOS bloque l'ouverture, faites un clic droit sur l'app > Ouvrir,
    ou lancez : xattr -cr /Applications/localmsg.app
  EOS
end
