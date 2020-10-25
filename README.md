# php-web-service default

This is docker image with simply configuration NGINX & PHP 7.4 in one container without any frameworks.

## Actions:

* Build image
* Remove image
* Create container
* Run container
* Remove container
* SSH
* Run composer install

### Build image 

* Windows CMD:
```batch
"./docker/bin/service.bat" build-image
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat build-image
```

### Create container

* Windows CMD:
```batch
"./docker/bin/service.bat" create-container
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat create-container
```

### Start container 

* Windows CMD:
```batch
"./docker/bin/service.bat" start-container
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat start-container
```

### Remove container 

* Windows CMD:
```batch
"./docker/bin/service.bat" remove-container
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat remove-container
```

### Run container 

* Windows CMD:
```batch
"./docker/bin/service.bat" run-container
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat run-container
```

### Remove image 

* Windows CMD:
```batch
"./docker/bin/service.bat" remove-image
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat remove-image
```

### Connect to container via ssh

* Windows CMD:
```batch
"./docker/bin/service.bat" ssh
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat ssh
```

### Run composer install

* Windows CMD:
```batch
"./docker/bin/service.bat" cmd-container "composer install"
```

* Windows PowerShell terminal:
```powershell
./docker/bin/service.bat cmd-container "composer install"
```

## Mounted directories
* `./` > `/var/www/web-server/`
* `./docker/nginx/welcome-html/` > `/var/www/welcome/`