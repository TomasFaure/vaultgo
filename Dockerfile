# Compila el binario estático dentro de un
# contenedor con todas las herramientas de Go.
FROM golang:1.25-alpine AS builder

# Dependencias de compilación
RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /app

# Copiar módulos primero para aprovechar el cache de Docker.
COPY go.mod go.sum ./
RUN go mod download

# Copiar el resto del código fuente
COPY . .

# Compilar el binario
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -trimpath \
    -o /app/server \
    ./cmd/server


# Imagen final mínima: solo el binario + certs.
# Sin Go toolchain, sin código fuente, ~15 MB.
FROM scratch AS runtime

# Certificados TLS (necesarios para conexiones HTTPS salientes)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Zona horaria (opcional, útil para logs con hora local)
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Copiar solo el binario compilado
COPY --from=builder /app/server /server

# Puerto que expone el servicio
EXPOSE 8080

# Usuario no-root para mayor seguridad
# scratch no tiene /etc/passwd, así que usamos UID numérico
USER 65532:65532

ENTRYPOINT ["/server"]