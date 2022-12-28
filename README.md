# media-ng stack

A docker compose to run a media server composed of

* plex
* qbitorrent
* openvpn support for the torrent client
* radarr/bazarr/sonarr

Every services are exposed with Caddy using two modules: 

* https://github.com/greenpau/caddy-security
* https://github.com/caddy-dns/cloudflare

One to provide SSL certificate with a domain hosted with cloudflare, and the other to support oauth2 with Google to authenticate user.

## Network

### Bridge mode

This *docker compose* need a existing network named **br-media**

```
docker network create --attachable --opt br-media 
```

If we want to define the exit IP we want to avoid the default masquerade rules

```
docker network create --attachable --opt 'com.docker.network.bridge.name=br-media'\
  --opt 'com.docker.network.bridge.enable_ip_masquerade=false'\
  --subnet=172.20.0.0/16 \
  br-media

sudo ip addr add 192.168.100.25/32 dev ens33
sudo iptables -t nat -A POSTROUTING -s 172.20.0.0/16 ! -o br-media -j SNAT --to-source 192.168.100.25
sudo iptables -t nat -A DOCKER -i br-media -j RETURN
```

In production the firewall will be apply after docker service as start


### macvlan

If we want to deploy it with macvlan ( network in compose need to be rename to dmz) and a IP in the range of *192.168.100.24/29* need to be set for the container Caddy only.

```sh
docker network create --attachable \
  --subnet=192.168.100.0/24 \
  --ip-range=192.168.100.24/29 \
  --gateway 192.168.100.1 \
  --aux-address="myserver=192.168.100.24" \
  -d macvlan \
  -o parent=ens33 \
  dmz

sudo ip link add dmz-docker-net link ens33 type macvlan mode bridge
sudo ip link set dmz-docker-net up
sudo ip addr add 192.168.100.24/29 dev dmz-docker-net
```

```
...
  caddy:
    #image: androw/caddy-security:latest
    image: y0ug/caddy-mods
    restart: unless-stopped
    networks:
      dmz:
        ipv4_address: 192.168.100.25
...
networks:
  dmz:
    external: true
  default:

```

