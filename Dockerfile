# syntax=docker/dockerfile:1

FROM golang:1.21
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
# Build
RUN go build -o /service
EXPOSE 8080
# Run
CMD ["/service"]