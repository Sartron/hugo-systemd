# Hugo systemd
Easily configure a Hugo site to be managed by systemd! Usage is simple, but be sure to read the additional setup below:
```
$ ./install.sh [FILE]
```

# Setup
In order for the script to work, there are a few requirements that need to be met first:
1. The `hugo` executable must be available under the shell's `$PATH` variable.
2. The environment file for the service unit must be in a directory 1 depth under the Hugo site directory. Below is an example of placing the environment files within directory `systemd` which is immediately underneath the root Hugo directory:
    ```
    <root Hugo directory>
    ├── archetypes
    ├── config
    ├── content
    ├── data
    ├── layouts
    ├── resources
    ├── static
    ├── themes
    └── systemd
       ├── development
       └── production
    ```

# Deployment
Running the shell script `install.sh` will move and rename the placeholder `hugo.service` under `~/.config/systemd/user` and populate it with the corresponding details of your environment file. **Please note that this script will clobber the existing service unit without confirmation.**  
Once this is done, it will automatically reload systemd and restart the service unit **if it was already running**. If the service is not already running, you will need to start it manually.  

Below is an example of how the deployment process works, using the `example` file in this repository as an example.
```
$ cat example
BIND=0.0.0.0
PORT=1313
ENVIRONMENT=development
BASEURL=http://example.tld
$ ./install.sh example-site/systemd/example
mkdir: created directory '/home/user/.config/systemd'
mkdir: created directory '/home/user/.config/systemd/user'
'hugo.service' -> '/home/user/.config/systemd/user/example@hugo.service'
inactive
$ systemctl --user cat example@hugo.service
# /home/user/.config/systemd/user/example@hugo.service
[Unit]
Description=Hugo Server
After=network.target

[Service]
Type=simple
EnvironmentFile=/home/user/example-site/systemd/example
ExecStart=/home/user/bin/hugo serve --appendPort=false "--baseURL=${BASEURL}" "--port=${PORT}" "--bind=${BIND}" '--source=/home/example-site' "--environment=${ENVIRONMENT}"
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
$
```