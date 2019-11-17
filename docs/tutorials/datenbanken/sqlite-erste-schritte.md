# SQLite: Erste Schritte

SQLite ist eine schlanke und kostenlose Datenbank, die dennoch für die meisten Anwendungsfälle ausreichend ist.
Lege einen neuen Ordner an und nenne ihn z.B. `sqlitedemo1`.

Auf der Seite [https://www.sqlite.org/download.html](https://www.sqlite.org/download.html) findest du unter der
Überschrift `Precompiled Binaries for Windows` ein Zip Archiv, dessen Namen mit `sqlite-dll-win64-x64-` beginnt,
gefolgt von der aktuellen Version. Lade dieses Zip und kopiere die DLL Datei aus dem Archiv in den Ordner `sqlitedemo1`.

Für den Zugriff auf die Funktionen der SQLite DLL benötigst du eine statische Import Bibliothek.
Siehe hierzu das Tutorial [Coff Import Bibliotheken erstellen](../grundlagen/coff-import-bibliotheken-erstellen.md).

Für D gibt es verschiedene Bibliotheken um auf SQLite zuzugreifen. In diesem Beispiel nutze
ich die [arsd-official Bibliothek](https://code.dlang.org/packages/arsd-official).
Erstelle eine neue Datei `application.d` mit folgenden Inhalt.:

```d
/+ dub.sdl:
    name "application"
    dependency "arsd-official:sqlite" version="4.2.0"
+/

import std;
import arsd.sqlite;

void main() 
{
    Database db = new Sqlite("demo.db");
    auto result = db.query(
        `SELECT name FROM sqlite_master 
        WHERE type='table' AND name=?`, "recipients");

    if (result.empty)
    {
        db.query(`CREATE TABLE recipients (
            ID INTEGER PRIMARY KEY AUTOINCREMENT, 
            FIRST_NAME TEXT NOT NULL,
            LAST_NAME TEXT NOT NULL
        )`);

        db.query(
            `INSERT INTO recipients (FIRST_NAME, LAST_NAME) 
            VALUES (?, ?);`, "John", "Doe");
    }

    foreach(row; db.query(`SELECT * FROM recipients`))
    {
        writeln(row);
    }
    readln();
}
```

Es wird eine SQLite Verbindung zu der Datei `demo.db` aufgebaut. Falls diese Datei noch nicht existiert,
wird sie im aktuellen Verzeichnis angelegt. Danach wird geprüft, ob die Tabelle `recipients` existiert.
Falls nicht, wird auch diese angelegt und danach ein neuer Datensatz eingefügt.
Am Ende werden alle Datensätze aus der Tabelle `recipients` ausgegeben.

Die Anwendung wird mit diesem Befehl erzeugt und gestartet:

```
dub application.d
```

Wenn du deine Anwendung weitergeben möchtest musst du die EXE + die DLL weitergeben.


