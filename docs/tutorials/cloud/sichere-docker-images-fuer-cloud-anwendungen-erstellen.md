# Sichere Docker images für cloud Anwendungen erstellen

Docker images können leicht mehrere hundert MB groß werden.
Während die Größe bei der Übertragung nur störend ist, stellen
die vielen unnötigen Komponenten ein Sicherheitsproblem dar.
Jede zusätzliche Komponente erhöht die Angriffsfläche und damit
die Gefahr auf einen erfolgreichen Angriff.

Ein Docker image sollte keine interaktiven tools wie z.B. `bash` enthalten,
sondern nur die Komponenten, die für den Betrieb unverzichtbar sind.
Durch die Verwendung des Docker `scratch` image, wird genau dieses Ziel erreicht.
Diese image enthält ein minimales Linux System ohne jegliche weitere Komponenten.
Dieses Tutorial zeigt anhand einer http server Anwendung,
wie ein sicheres Docker image für den cloud Betrieb erstellt werden kann. 

Erstelle eine Datei `app.d` mit diesem Inhalt:

``` d
/+ dub.sdl:
    name "app"
    dependency "vibe-d:http" version="0.8.6"
    dependency "vibe-d:tls" version="*"
    subConfiguration "vibe-d:tls" "openssl-1.1"
+/

import std.process : environment;
import vibe.core.core : runApplication;
import vibe.http.server;

void main()
{
    string port = environment.get("PORT", "8080");
    listenHTTP("0.0.0.0:" ~ port, &handleRequest);
    runApplication();
}

private void handleRequest(HTTPServerRequest req, HTTPServerResponse res)
{
    if (req.path == "/")
        res.writeBody("Hello, World!");
}
```

Die Umgebungsvariable `PORT` wird ausgelesen und der http Server für diesen
Port gestartet. Falls die Umgebungsvariable nicht definiert ist, wird als
Port `8080` verwendet.

Erstelle eine Datei `Dockerfile` mit diesem Inhalt:

``` dockerfile
FROM ubuntu:focal as base

RUN apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y build-essential ldc dub zlib1g-dev libssl-dev

COPY app.d /tmp
RUN dub build --single /tmp/app.d
RUN mkdir -p /dist/opt/ && cp /tmp/app /dist/opt/

WORKDIR /dist
RUN { ldd /dist/opt/app; } | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname ./%); cp % ./%;'

FROM scratch as final
COPY --chown=0:0 --from=base /dist /
COPY --from=base /etc/passwd /etc/passwd
COPY --from=base /etc/group /etc/group

USER www-data
ENV LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:/lib64:/usr/lib/x86_64-linux-gnu
CMD ["/opt/app"]
```

Das Dockerfile besteht aus den zwei stages `base` und `final`. Im stage `base` wird der LDC compiler und zusätzliche Abhängigkeiten installiert. Danach wird die http server Anwendung kompiliert und nach `/dist/opt/` kopiert.
Am Ende von stage `base` werden alle zusätzlichen Abhängigkeiten (Dynamische Bibliotheken) der 
Anwendung ermittelt und in ein Unterverzeichnis von `/dist/` kopiert.

Nur die Dateien, die sich im stage `final` befinden, werden auch im Docker image verfügbar sein.
Der Inhalt von `/dist` wird aus dem `base` stage nach `final` kopiert.
Um die Sicherheit weiter zu erhöhen, wird der Benutzer `www-data` gesetzt. Dies erfordert,
das zuvor die Dateien `/etc/passwd` und `/etc/group` aus stage `base` nach `final` kopiert werden.

Stage `final` endet mit der Angabe, unter welchen Pfaden die dynamischen Bibliotheken zu finden sind
und die http server Anwendung wird als Docker image Startanwendung gesetzt.

Öffne eine Kommandozeile und erstelle das Docker image mit `docker build`. Danach starte einen 
container mit `docker run`:

``` bash
docker build -t sample .
docker run -it --rm -p 8080:8080 sample
```

Öffne einen webbrowser. Der http server ist unter der Adresse [http://localhost:8080](http://localhost:8080) erreichbar.
