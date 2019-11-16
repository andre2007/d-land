# Coff Import Bibliotheken erstellen

Um auf Funktionen zuzugreifen, die in einer Windows DLL bereit gestellt werden,
gibt es einmal die Möglichkeit eine statische Import Bibliothek zu erstellen oder
dynamisch auf die Funktionen zuzugreifen.
Dieses Tutorial beschreibt, wie für eine DLL eine statische Coff Import Bibliothek
erstellt werden kann.


## Installation

In dem Archiv [llvm-9.0.0-windows-x64.7z](https://github.com/ldc-developers/llvm/releases/download/ldc-v9.0.0/llvm-9.0.0-windows-x64.7z) befindet
sich im Verzeichnis ```bin``` die Datei ```llvm-dlltool.exe```. Entpacke diese Datei auf deinen PC und füge den Pfad
zu der Datei, zur Umgebungsvariable ```PATH``` hinzu.

 
## Verwendung

In diesem Beispiel wird eine Import Bibliothek für SQLite erstellt. Lade von [https://www.sqlite.org/download.html](https://www.sqlite.org/download.html)
das Zip Archive ```64-bit DLL (x64) for SQLite``` auf deinen PC und entpacke die DLL und die DEF Datei.

In der Windows Kommandozeile führe diesen Befehl aus, um für die DLL ```sqlite3.dll``` und die DEF Datei ```sqlite3.def```
eine Import Bibliothek mit dem Namen ```sqlite3.lib``` und der Architektur ```x86_64``` zu erstellen.

```
llvm-dlltool.exe -D sqlite3.dll -d sqlite3.def -l sqlite3.lib -m i386:x86-64
```