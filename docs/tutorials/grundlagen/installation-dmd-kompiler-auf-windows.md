# Installation DMD Kompiler auf Windows

## Installation

Lade von [https://dlang.org/download.html](https://dlang.org/download.html)
den DMD Kompiler für Windows im 7z Archivformat.
Entpacke das Archiv nach `C:\D`. Danach füge den Pfad `C:\D\dmd2\windows\bin` zu der
Windows Umgebungsvariable `PATH` hinzu.

## Installationstest

Erstelle eine neue Datei mit dem Namen `helloworld.d` und folgenden Inhalt:

```d
import std.stdio;

void main()
{
    writeln("Hello World!");
}
```

Mit diesem Befehl wird der Quellcode kompiliert und die Anwendung direkt gestartet:

```
dmd -run helloworld.d
```