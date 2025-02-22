FROM golang:1.22.10 as builder
ARG TARGET_GOOS
ARG TARGET_GOARCH
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    TARGET_GOOS=${TARGET_GOOS} \
    TARGET_GOARCH=${TARGET_GOARCH} \
    CONTAINER_BUILD=1

WORKDIR /go/src/github.com/cloudflare/cloudflared/
COPY . .
RUN .teamcity/install-cloudflare-go.sh
RUN PATH="/tmp/go/bin:$PATH" make cloudflared

FROM gcr.io/distroless/base-debian11:nonroot
LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# 将构建好的二进制文件复制到 distroless 镜像
COPY --from=builder --chown=nonroot /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

# 指定用户
USER nonroot

# 容器的默认入口点
ENTRYPOINT ["cloudflared", "--no-autoupdate", "tunnel", "run"]

# 默认命令，可以通过 --token 覆盖
CMD ["--token", "eyJhIjoiZjc2NTIwZGQ3NzA4MTFkMmM1MDdjNWU1ODg2MGY5YmIiLCJ0IjoiODVkOGE0NWQtOTg3Yy00YjcwLTg4ZTktYWU3NGUyZDZlMjUyIiwicyI6Ik5ESXdabU5sTmpJdE1UVTJZUzAwWmpZMExUbGhZbVF0TW1JNFkyVXlOalZpTm1RNSJ9"]
