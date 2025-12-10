# Podman Desktop proxy setup with simple local Squid Proxy running in container

## Setup Squid running in container

1. Create a squid config on local file system, `squid.conf`:
```
http_port 3128

http_access allow all

http_access deny all

cache_dir ufs /var/spool/squid 100 16 256

access_log daemon:/var/log/squid/access.log squid
```

2. Start up the squid container:
```
podman run -d -p 3128:3128 --name squid-proxy -v ./squid.conf:/etc/squid/squid.conf:Z docker.io/ubuntu/squid:latest
```

3. Open another terminal window and monitor the squid log
```
podman logs -f squid-proxy # container log
# or
podman exec -it squid-proxy /bin/tail -f /var/log/squid/access.log # squid access.log or cache.log
```

## Setup Podman Desktop to use the proxy, similar to web browser using transparent proxy, application level

### Setup proxy via GUI
1. Open Podman Desktop
2. Settings -> Proxy
3. http and https proxy set to `http://localhost:3128`
4. Quit/exit Podman Desktop

### Setup proxy via user settings
1. Create settings.json with content:
```
{ 
  "proxy.enabled": 1,
  "proxy.http": "http://localhost:3128",
  "proxy.https": "http://localhost:3128",
  "proxy.no": "testing"
}
```
2. Place the file on expected path, depends on version and installation, linux: (`~/.config/containers/podman-desktop/`, `.var/app/io.podman_desktop.PodmanDessktop/config/containers/podman-desktop/`, `~/.local/share/containers/podman-desktop/configuration/`)

### Check proxy working for podman desktop app
1. Start Podman Desktop
1. Check all works in Podman desktop (extensions catalog, opening external sites via dashboard)
2. Proxy log shows access info for request coming from PD, ie:
```
1765353823.956   4090 192.168.50.145 TCP_TUNNEL/200 8841 CONNECT podman-desktop.io:443 - HIER_DIRECT/185.199.111.153 -
1765353824.561   4585 192.168.50.145 TCP_TUNNEL/200 50528 CONNECT github.com:443 - HIER_DIRECT/140.82.121.3 -
1765354354.476 576636 192.168.50.145 TCP_TUNNEL/200 8316 CONNECT registry.podman-desktop.io:443 - HIER_DIRECT/185.199.110.153 -

```
3. Open devtools console, check for errors
4. No errors for github when we are trying to reach for cli tools info