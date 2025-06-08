#!/bin/bash

if [[ -z "$ROOT_PASSWORD" || -z "$NGROK_TOKEN" ]]; then
  echo "[ERROR] Required environment variables ROOT_PASSWORD and NGROK_TOKEN are not set."
  exit 1
fi

echo "root:$ROOT_PASSWORD" | chpasswd

sed -i 's/#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

service ssh start
ngrok config add-authtoken "$NGROK_TOKEN"
ngrok tcp 22 > /var/log/ngrok.log &

for i in {1..10}; do
  sleep 2
  NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o 'tcp://[^"]*')
  if [[ -n "$NGROK_URL" ]]; then
    echo "[INFO] SSH is available at: $NGROK_URL"
    break
  fi
done

if [[ -z "$NGROK_URL" ]]; then
  echo "[ERROR] Failed to get ngrok address"
fi

tail -f /dev/null
