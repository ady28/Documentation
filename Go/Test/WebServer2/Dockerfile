FROM golang:1.17.5-bullseye AS builder

WORKDIR /go/srv/Test/WebServer2

COPY go.* .

RUN go get -d -v ./...

COPY . .

RUN go build -v ./...


FROM ubuntu:20.04

ARG APIPORT=8080

WORKDIR /app

COPY --from=builder /go/srv/Test/WebServer2/WebServer2 .

ENV PORT=$APIPORT
ENV MONGODBSERVERNAME=172.17.0.2
ENV MONGODBSERVERPORT=27017

EXPOSE $PORT

CMD ["./WebServer2"]