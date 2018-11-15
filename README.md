# shadowsocks-server

## default

```sh
PORT        8388
METHOD      aes-256-gcm
PASSWORD    123456
TIMEOUT     300
DNS         8.8.8.8
```

## run

```sh
docker run --restart=always -itd -p 8388:8388 -p 8388:8388/udp -e "PASSWORD=123456" modules/shadowsocks-server
```
