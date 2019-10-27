# Installation LDC auf Windows Subsystem für Linux

## Windows Subsystem für Linux installieren

Starte den Microsoft Store über `Windows Start` und der Eingabe `Store`.
Suche nach `Ubuntu 18.04 LTS`. Klicke auf `Herunterladen` und danach auf `Starten`.
Ubuntu ist kostenlos verfügbar, eine Anmeldung im Store ist nicht notwendig.

Starte Windows Powershell als Administrator und führe diesen Befehl aus:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

Im Windows Startmenü starte die Anwendung `Ubuntu 18.04 LTS`.
Beim ersten Start kann ein Benutzername und Passwort vergeben werden.

Führe danach diesen Befehl aus um verschiedene Entwickler Pakete zu installieren:

```bash
sudo apt-get update && sudo apt-get install --yes build-essential
```

## LDC installieren

Führe in der Ubuntu Bash diesen Befehl aus um den Download von LDC 1.18.0 zu starten.

```bash
curl -OL https://github.com/ldc-developers/ldc/releases/download/v1.18.0/ldc2-1.18.0-linux-x86_64.tar.xz
```

Mit dem Befehl `tar` kann das Archiv entpackt werden.
Danach kann das nicht mehr benötigte Archiv mit dem Befehl `rm` gelöscht werden.

```bash
tar -xf ldc2-1.18.0-linux-x86_64.tar.xz
rm ldc2-1.18.0-linux-x86_64.tar.xz
```

Füge den Pfad `./ldc2-1.18.0-linux-x86_64/bin` zur Umgebungsvariable `PATH` hinzu,
indem du die Datei `~/.profile` editierst. In diesem Beispiel wird diese Zeile angehängt:

```bash
PATH=$PATH:/home/user/ldc2-1.18.0-linux-x86_64/bin
```

## Installationstest

Lege unter Windows eine Datei `helloworld.d` und diesem Inhalt an:

```d
import std.stdio;

void main()
{
    writeln("Hello World!");
}
```

Öffne eine DOS Konsole und gib diesen Befehl ein um die Anwendung unter Linux zu Kompilieren und zu Starten:

```batch
wsl ldc2 -run helloworld.d
```