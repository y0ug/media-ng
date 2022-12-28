Building the caddy mod behind a proxy 

```
docker compose build --build-arg https_proxy=${https_proxy}
```

Proxy need to allow

```
proxy.golang.org
sum.golang.org
storage.googleapis.com
google.golang.org
github.com
```


