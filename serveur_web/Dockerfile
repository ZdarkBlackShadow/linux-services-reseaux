FROM golang:1.24-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o server main.go

RUN go build -o dbtool migration/database.go

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache bash ca-certificates

COPY --from=builder /app/server .
COPY --from=builder /app/dbtool .

COPY --from=builder /app/assets ./assets
COPY --from=builder /app/views ./views
COPY --from=builder /app/public ./public

COPY --from=builder /app/.env.example .env

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]