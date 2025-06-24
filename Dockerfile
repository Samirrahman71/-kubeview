# Builder stage
FROM golang:1.21 AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o kubeview ./cmd

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/kubeview .

EXPOSE 8080

ENTRYPOINT ["./kubeview"]
