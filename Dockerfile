FROM ubuntu:focal

RUN apt update && apt install -y python3 python3-pip
COPY . /tmp
RUN pip3 install -r /tmp/requirements.txt
WORKDIR /tmp
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]