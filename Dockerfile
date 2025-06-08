FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y openssh-server curl unzip && \
    mkdir /var/run/sshd

# 安装 Ngrok（自动适配架构）
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
      amd64) NGROK_ARCH=amd64 ;; \
      arm64) NGROK_ARCH=arm64 ;; \
      armhf) NGROK_ARCH=arm ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    curl -s -L -o ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${NGROK_ARCH}.tgz && \
    tar -xzf ngrok.tgz -C /usr/local/bin && rm ngrok.tgz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
CMD ["/entrypoint.sh"]
