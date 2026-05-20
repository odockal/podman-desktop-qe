# Podman Desktop proxy setup with simple local Squid Proxy running in container

## Setup Squid running in container - simple, open to all

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
podman run -d -p 3128:3128 --name squid-proxy -v ./squid-basic.conf:/etc/squid/squid.conf:Z docker.io/ubuntu/squid:latest
```

## Setup squid running in a container with access allowed only from local network

1. Create a `squid-local.conf`
```
# 1. Define the port Squid listens on
http_port 3128

# 2. Define standard local private networks (covers Docker, CI runners, and LANs)
acl localnet src 10.0.0.0/8      # RFC 1918 private cloud/LAN
acl localnet src 172.16.0.0/12    # RFC 1918 private cloud/LAN (Typical Docker range)
acl localnet src 192.168.0.0/16  # RFC 1918 home/office LAN
acl localnet src fc00::/7        # IPv6 unique local addresses
acl localnet src fe80::/10       # IPv6 link-local addresses

# 3. Define allowed ports and methods
acl SSL_ports port 443
acl Safe_ports port 80          # HTTP
acl Safe_ports port 443         # HTTPS
acl CONNECT method CONNECT

# 4. Traffic Protection Rules
# Drop traffic attempting to access non-standard ports
http_access deny !Safe_ports

# Only allow the CONNECT method for actual SSL/HTTPS ports
http_access deny CONNECT !SSL_ports

# 5. Access Control Rules (Evaluated top-down)
http_access allow localhost
http_access allow localnet

# Catch-all: Deny anything else (stops your proxy from being an open internet proxy)
http_access deny all
```

2. Start up the squid container:
```
podman run -d -p 3128:3128 --name squid-proxy -v ./squid-local.conf:/etc/squid/squid.conf:Z docker.io/ubuntu/squid:latest
```

### Verification of the proxy setup

1. Open another terminal window and monitor the squid log
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