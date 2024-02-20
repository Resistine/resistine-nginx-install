# ***resistine-nginx-install***
##*** Info ***
 Nginx and ModSecurity installation from source for Ubuntu server.
 easy install with ci pipelines . there are two pipelines for installation :
###***1. Docker on ubuntu image (nginx_docker_install.yml):***
   runs-on: [self-hosted, docker-nginx]
###***2. Ubuntu Serever  (nginx_server_install.yml):***
   runs-on: [self-hosted, nginx]

##*** Running pipelines:

  ***connecting github runner to github project:***
    You can see list of runners on settings page in [actions]
    (https://github.com/Resistine/resistine-nginx-install/settings/actions/runners) section :

    Create new runner via easy configurator through one [click]
    (https://github.com/Resistine/resistine-nginx-install/settings/actions/runners/new?arch=x64&os=linux) :

    After You set up runner with correct LABELS, you are simply ready to [deploy]
    (https://github.com/Resistine/resistine-nginx-install/actions), to runners and check the LABELS and runner status:
  ***!!! always check LABELS and active runners before you run the pipeline !!!***

    Now chose your installation type ... for example [nginx server install]
    (https://github.com/Resistine/resistine-nginx-install/actions/workflows/nginx_server_install.yml):
    >and it's time for coffee , install takes around 5 minutes depending on hardware you chose.   
