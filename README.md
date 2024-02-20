  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="assets/img/R_logo.png">
</picture>
 
 
# resistine-nginx-install

## Info:

 Nginx and ModSecurity installation from source for Ubuntu server.

 Easy install with ci pipelines . there are two pipelines for installation.
 

### 1. Docker on ubuntu image (nginx_docker_install.yml): 
  - runs-on: [self-hosted, docker-nginx]

### 2. Ubuntu Serever  (nginx_server_install.yml): 
  - runs-on: [self-hosted, nginx]

### 3. clone repo and run install script on Ubuntu host:
  - git clone https://github.com/Resistine/resistine-nginx-install.git install
  - cd install
  - chmod +x install.sh
  - sudo ./install.sh


## Running pipelines: ##


 ### connecting github runner to github project: ###
  -  You can see list of ***runners*** on settings page in ***[actions](https://github.com/Resistine/resistine-nginx-install/settings/actions/runners)*** section.

  -  Create new runner via easy ***runner configurator*** through one ***[click](https://github.com/Resistine/resistine-nginx-install/settings/actions/runners/new?arch=x64&os=linux)***.

  -  After You set up runner with correct ***LABELS***, you are simply ready to ***[deploy](https://github.com/Resistine/resistine-nginx-install/actions)***, to ***runners*** and check the ***LABELS*** and runner status.
>  [!CAUTION]
>  *** !!! always check ***LABELS*** and active ***runners*** before you run the pipeline !!! ***

  -  Now chose your installation type ... for example ***[nginx server install](https://github.com/Resistine/resistine-nginx-install/actions/workflows/nginx_server_install.yml)***.
  - -   and it's time for coffee :+1: , install takes around 5 minutes depending on hardware you chose.


## Next plans: ##

- [x] installation test on docker
- [x] installation test on server
- [ ] add script for packaging build to deb package
- [ ] Add delight to the experience when all tasks are complete :tada:
- [ ] and maybee many more 👋
