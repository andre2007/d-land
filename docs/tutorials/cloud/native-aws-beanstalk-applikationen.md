# Native AWS Elastic Beanstalk Applikationen

Es gibt 2 Möglichkeiten in D geschriebene Anwendungen auf AWS Elastic Beanstalk zu verwenden.
Eine Möglichkeit ist die D Anwendung als Docker Container in Elastic Beanstalk auszuführen.
Die zweite Möglichkeit ist als Platform `Go` anzugeben und die D Anwendung innerhalb eines
ZIP Archivs an Elastic Beanstalk zu übergeben.
Dieses Tutorial beschreibt die Verwendung der `Go` Platform.

Voraussetzung für dieses Tutorial ist die Installation von
[LDC auf WSL](../grundlagen/installation-ldc-auf-windows-subsystem-fuer-linux.md).

## Webserver-Umgebung

Erstelle eine neue Datei `application.d` mit folgendem Inhalt:

```d
/+ dub.sdl:
    name "application"
    dependency "vibe-d:http" version="0.8.6-alpha.2"
    dependency "vibe-d:tls" version="*"
    subConfiguration "vibe-d:tls" "notls"
+/

import vibe.core.core : runApplication;
import vibe.http.server;

void main() {
    listenHTTP(":5000", &handleRequest);
    runApplication();
}

void handleRequest(HTTPServerRequest req, HTTPServerResponse res)
{
    if (req.path == "/")
        res.writeBody("Hello, World!");
}
```

Mit Hilfe von [vibe.d](http://vibed.org/) wird ein HTTP Server auf dem Port `5000` gestartet.
AWS Elastic Beanstalk erwartet eine unter Linux ausführbare Datei.
Starte eine Windows Kommandozeile und gib folgenden Befehl ein.

```batch
wsl dub build --single application.d -b plain
```

Eine unter Linux ausführbare Datei mit dem Namen `application` wurde erstellt.
Führe diesen Befehl aus um deine Applikation in eine Zip Datei zu packen:

```
wsl zip -r app.zip ./application
```

Dadurch dass das Linux Tool `zip` verwendet wird, behält die Datei `application` auch die Information,
dass es sich um eine ausführbare Datei handelt.

Auf AWS Elastic Beanstalk kannst du nun eine neue Webserver-Umgebung anlegen,
als Platform `Go` wählen und die Datei `app.zip` auswählen.

## Worker-Umgebung

AWS gibt in seiner aktuellen Dokumentation an, dass SQS Nachrichten als HTTP requests
an Port `80` der Server Anwendungen geschickt werden.
Für die Go Platform ist das nicht korrekt. Hier muss die Server Anwendung,
wie auch bei der Webserver-Umgebung, auf Port `5000` eingestellt sein.

In diesem Beispiel benutze ich die HTTP Server Komponente
[arsd-official:cgi](https://code.dlang.org/packages/arsd-official).

```d
/+ dub.sdl:
    name "application"
    dependency "arsd-official:cgi" version="4.0.1"
    subConfiguration "arsd-official:cgi" "embedded_httpd"
+/

import arsd.cgi;

void main() 
{
    cgiMainImpl!(handle, Cgi, defaultMaxContentLength)(["--port", "5000"]);
}

void handle(Cgi cgi)
{
    if (cgi.requestMethod == cgi.RequestMethod.POST && cgi.requestUri == "/")
    {
        string json = cgi.postJson;
        cgi.setResponseStatus("200 OK");
    }
    else cgi.setResponseStatus("404 File Not Found");
}
```

Auch hier wird wieder ein HTTP Server auf Port `5000` gestartet.
Den Inhalt der SQS Message wird in der Variable `json` gespeichert
und kann weiter ausgewertet werden.

Genauso wie bei der Webserver Elastic Beanstalk Anwendung muss die Applikation
wieder unter Linux kompiliert und in eine Zip Datei gepackt werden.

## .ebextensions

Über Konfigurationsdateien in einem Ordner `.ebextensions` können Startparameter
für die AWS Elastic Beanstalk Applikation gesetzt werden.

Falls z.B. die Anwendung unter Windows in ein Zip Archiv gepackt wurde,
geht das Executable Kennzeichen verloren. Dieses Kennzeichen kann nachträglich
wieder gesetzt werden, wie im folgenden Beispiel beschrieben.

Erstelle einen Ordner mit dem Namen `.ebextensions` und eine Datei `set_perms.config`
innerhalb dieses Ordners mit folgendem Inhalt:

```
container_commands:
  set_perms:
    command: "chmod 777 application"
```

Füge den Ordner `.ebextensions` dem Zip Archiv hinzu.