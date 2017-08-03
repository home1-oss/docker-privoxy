
# docker-privoxy
Privoxy proxy

http-to-socks
```sh
export HTTP_TO_SOCKS_PORT=28118
export SOCKS_PROXY=<e.g. socks5://127.0.0.1:1080>
```

smart-http-proxy
```sh
export UPSTREAM_PROXY_HOST_PORT=28119
export UPSTREAM_PROXY_HOST_PORT=<e.g. http-to-socks.local:28118>
```

## debug

see: http://config.privoxy.org/show-url-info
