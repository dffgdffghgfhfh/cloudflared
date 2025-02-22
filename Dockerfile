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

# 使用 debian 镜像
FROM debian:bullseye-slim
LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# 安装 bash 和其他可能需要的工具
RUN apt-get update && apt-get install -y bash

# 将构建好的二进制文件复制到镜像中
COPY --from=builder --chown=root /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

# 切换为 root 用户
USER root

# 容器的默认入口点
ENTRYPOINT ["cloudflared", "--no-autoupdate", "tunnel", "run"]

# 默认命令，可以通过 --token 覆盖
CMD ["--token", "eyJhIjoiZjc2NTIwZGQ3NzA4MTFkMmM1MDdjNWU1ODg2MGY5YmIiLCJ0IjoiODVkOGE0NWQtOTg3Yy00YjcwLTg4ZTktYWU3NGUyZDZlMjUyIiwicyI6Ik5ESXdabU5sTmpJdE1UVTJZUzAwWmpZMExUbGhZbVF0TW1JNFkyVXlOalZpTm1RNSJ9"]
