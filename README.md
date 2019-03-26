# WebShell

Based on seashellls and hermit. To run it, do:
```
docker build -t webshell .
```
Then run:
```
docker run -t -p 1337:1337 -p 8090:8090 webshell
```

In order to mount the logs to the outside:
```
docker run -t -v /your/path:/webshell/logs webshell
```
