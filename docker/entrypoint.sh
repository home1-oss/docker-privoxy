#!/bin/sh

sed -i "s#listen-address  127.0.0.1:8118#listen-address  0.0.0.0:8118#g" /etc/privoxy/config
PORT="8118"
WALL_ACTION="actionsfile wall.action"

if [ ! -z "${HTTP_TO_SOCKS_PORT}" ] && [ ! -z "${SOCKS_PROXY}" ]; then
    echo "HTTP_TO_SOCKS_PORT=${HTTP_TO_SOCKS_PORT}"
    PORT="${HTTP_TO_SOCKS_PORT}"

    echo "SOCKS_PROXY=${SOCKS_PROXY}"
    PROXY_PROTOCOL="$(echo ${SOCKS_PROXY} | awk -F:// '{print $1}')"
    PROXY_HOST_PORT="$(echo ${SOCKS_PROXY} | awk -F:// '{print $2}')"
    echo "PROXY_PROTOCOL=${PROXY_PROTOCOL} PROXY_HOST_PORT:${PROXY_HOST_PORT}"
    case "${PROXY_PROTOCOL}" in
        socks*)
        PRIVOXY_FORWARD="forward-${PROXY_PROTOCOL} / ${PROXY_HOST_PORT} ."
        if ! grep "${PRIVOXY_FORWARD}" /etc/privoxy/config; then
            if ! grep -E "^forward-" /etc/privoxy/config; then
                echo "${PRIVOXY_FORWARD}" >> /etc/privoxy/config
                # 10.0.0.0/8~10.255.255.255/8
                # 172.16.0.0/12~172.31.255.255/12
                # 192.168.0.0/16~192.168.255.255/16
                echo "forward 10.*.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.16.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.17.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.18.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.19.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.20.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.21.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.22.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.23.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.24.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.25.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.26.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.27.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.28.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.29.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.30.*.*/ ." >> /etc/privoxy/config
                echo "forward 172.31.*.*/ ." >> /etc/privoxy/config
                echo "forward 192.168.*.*/ ." >> /etc/privoxy/config
                echo "forward 127.*.*.*/ ." >> /etc/privoxy/config
            else
                sed -i -E "s#^forward-.*#${PRIVOXY_FORWARD}#g" /etc/privoxy/config
            fi
        fi
        ;;
        *)
        echo "unsupported SOCKS_PROXY '${SOCKS_PROXY}'"
        exit 1
        ;;
    esac
elif [ ! -z "${SMART_HTTP_PROXY_PORT}" ] && [ ! -z "${UPSTREAM_PROXY_HOST_PORT}" ]; then
    echo "SMART_HTTP_PROXY_PORT=${SMART_HTTP_PROXY_PORT}"
    PORT="${SMART_HTTP_PROXY_PORT}"

    echo "UPSTREAM_PROXY_HOST_PORT=${UPSTREAM_PROXY_HOST_PORT}"
    (
    echo "{+forward-override{forward ${UPSTREAM_PROXY_HOST_PORT}}}"
    echo ".amazonaws.com"
    echo ".facebook.com"
    echo ".fbcdn.net"
    echo ".gcr.io"
    echo ".gmail.com"
    echo ".google.com"
    echo ".google.com.hk"
    echo ".gstatic.com"
    echo ".s3.amazonaws.com"
    echo ".sourceforge.net"
    echo ".twitter.com"
    echo ".youtube.com"
    )>/etc/privoxy/wall.action
    chown privoxy:privoxy /etc/privoxy/wall.action
    chmod 660 /etc/privoxy/wall.action

    if ! grep "${WALL_ACTION}" /etc/privoxy/config; then
        echo "${WALL_ACTION}" >> /etc/privoxy/config
    fi
else
    sed -i "/${WALL_ACTION}/d" /etc/privoxy/config && rm -f /etc/privoxy/wall.action
fi

sed -i -E "s#listen-address  0.0.0.0:[0-9]+#listen-address  0.0.0.0:${PORT}#g" /etc/privoxy/config
#waitforit -full-connection=tcp://127.0.0.1:${PORT} -timeout=180

exec "$@"
