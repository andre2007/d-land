
# HTML5 Anwendungen mit GTK3 schreiben

GTK3 ist zwar primär für die Erstellung von Desktop Anwendungen gedacht,
mit der Erweiterung [Broadway](https://developer.gnome.org/gtk3/stable/gtk-broadway.html)
lassen sich Anwendungen aber auch im Browser
darstellen. Um Betriebssystem unabhängig zu sein, lassen wir Broadway und
die GTK3 Anwendung in einem docker container laufen.

Erstelle eine Datei `app.d` mit folgendem Inhalt:

```d
iimport core.runtime : Runtime;
import std.algorithm, std.array, std.conv;
import gtk;

pragma(lib, "gtk-3");
pragma(lib, "glib-2.0");
pragma(lib, "pango-1.0");
pragma(lib, "gobject-2.0");
pragma(lib, "cairo");
pragma(lib, "atk-1.0");
pragma(lib, "gio-2.0");

void activate(GtkApplication* app, gpointer user_data)
{
  GtkWidget* window;
  window = gtk_application_window_new(app);
  gtk_window_set_title( cast(GtkWindow*) window, "Window");
  gtk_window_set_default_size( cast(GtkWindow*) window, 200, 200);
  gtk_widget_show_all(window);
}

int main()
{
  GtkApplication* app;
  int status;
  app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE);
  g_signal_connect_object(app, "activate", cast(GCallback) &activate, NULL, G_CONNECT_SWAPPED);
  status = g_application_run(cast(GApplication*) app, Runtime.cArgs.argc, Runtime.cArgs.argv);
  
  g_object_unref(app);
  return status;
}
```

Dieses coding zeigt ein leeres Fenster an und ist eine
Übersetzung von der [C Beispiel Anwendung](https://developer.gnome.org/gtk3/stable/gtk-getting-started.html)
nach D.

Erstelle eine Datei `gtk.dpp` mit diesem Inhalt:

```C
#include <gtk/gtk.h>
```

Das Modul `gtk.dpp` ermöglicht den Zugriff auf die C header Dateien von GTK3.

Erstelle eine Datei `Dockerfile` mit diesem Inhalt:

```docker
FROM dlang2/ldc-ubuntu:1.19.0 as base

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y clang-9 libclang-9-dev libgtk-3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/clang-9 /usr/bin/clang

COPY gtk.dpp /tmp/

RUN DFLAGS="-L=-L/usr/lib/llvm-9/lib/" dub run dpp -- /tmp/gtk.dpp \
    --include-path /usr/include/gtk-3.0 \
    --include-path /usr/include/glib-2.0 \
    --include-path /usr/include/pango-1.0 \
    --include-path /usr/include/cairo \
    --include-path /usr/include/gdk-pixbuf-2.0 \
    --include-path /usr/include/atk-1.0 \
    --include-path /usr/lib/x86_64-linux-gnu/glib-2.0/include \
    --preprocess-only
   
COPY app.d /tmp/
RUN DFLAGS="-L=-L/usr/lib/x86_64-linux-gnu/" ldc2 /tmp/app.d /tmp/gtk.d -of=/tmp/app
 
###############################################################################
## final image
FROM debian:buster-slim

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y libgtk-3-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
  
COPY --from=base /tmp/app /tmp/app
COPY start.sh /tmp/
CMD ["/tmp/start.sh"]
```

Das docker image wird in 2 Phasen gebaut.
In Phase 1 wird [DPP](https://code.dlang.org/packages/dpp) verwendet um aus den
GTK3 C header Dateien ein D Modul `gtk.d` zu erzeugen.
Dieser Schritt kann einige Minuten dauern.
Das generierte Modul `gtk.d` wird zusammen mit dem
Modul `app.d` zu einer ausführbaren Datei `/tmp/app` kompiliert.

In Phase 2 wird die ausführbare Datei `/tmp/app` aus Phase 1 rüber kopiert
und das shell script `start.sh` als container Startkommando gesetzt.

Erstelle eine Datei `start.sh` mit diesem Inhalt:

```bash
#!/bin/sh
export GDK_BACKEND broadway
broadwayd -p 8889 :0 &
/tmp/app
```

Das shell script `start.sh` setzt die Umgebungsvariable `GDK_BACKEND` auf `broadway`.
Damit wird die HTML5 Ausgabe aktiviert. Die server Komponente `broadwayd` wird im
Hintergrund gestartet. Zuletzt wird die eigentliche Anwendung `/tmp/app` gestartet.

Baue das docker image mit dem Befehl:

```bash
docker build -t t1 .
```

und starte danach einen container mit diesem Befehl:

```bash
docker run -p 8889:8889 t1
```

Im browser kannst du die Anwendung unter der Adresse
http://localhost:8889 aufrufen.
