FROM golang:1.21-alpine as build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o /auth-api .

FROM alpine:latest

WORKDIR /

COPY --from=build-stage /auth-api /auth-api

EXPOSE 8081

ENTRYPOINT ["/auth-api"]
