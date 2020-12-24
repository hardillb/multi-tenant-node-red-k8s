# Multi Tenant Node-RED Kubernetes

A collection of Containers and definition files that will implement a Multi Tenant Node-RED environment on Kubernetes.

## Download

```
$ git clone --recurse-submodules https://github.com/hardillb/multi-tenant-node-red-k8s.git
```

## Pre-reqs

### Creating secrets and setting domain

Running `./setup.sh` in the root directory of the project will generate a `deployment/secret.yml` file that holds the details for connecting to the Kubernetes API and and the `settings.js` for the management app.

This script will also set the root domain, if a value is passed as an argument to the script it will use this, otherwise it will use the current hostname with `.local` appened

```
$ ./setup.sh example.com
```

### Build containers

Both the Custom Node-RED and the management containers need building and pushing to your local container registry.

```
$ docker build -t private.example.com/custom-node-red ./manager
...
$ docker push private.example.com/custom-node-red
```
and
```
$ docker build -t private.example.com/k8s-manager ./manager
...
$ docker push private.example.com/k8s-manager
```

Once this is done you will need to edit the `deployment/deployment.yml` and `manager/config/settings.js` file to update management container path and the custom-node-red path respectively.


## Deploying

```
$ kubectl apply -f ./deployment
```

### DNS

You will need to configure your DNS server to point a wildcard A/AAAA record at the Ingress IP address for your cluster.

To test you add entries for to the `/etc/hosts` file as follows:

```
192.168.1.100   manager.example.com  r1.example.com  r2.example.com
```

Where `192.168.1.100` is the IP address of the Ingress node. 

## Private Node Repository

### npm

The npm repository is available on `registry.example.com`. You can publish new nodes to this repo under the scope of `@private` using the username `admin` and the password `password`

To add the scope to your local npm config run the following:

```
npm login --registry=http://registry.example.com --scope=@private
```

Once this is setup you can publish any package with the scope `@private` to that repository with the normal `npm publish` command

You can access the web front end for the repository on `http://registry.example.com`.

### Catalogue

You can edit the `catalogue.json` file in the catalogue directory as required using the `build-catalogue.js` in the manager directory.

`node build-catalogue.js registry.example.com [keyword filter] > ../catalogue/catalogue.json`

Where the first argument is the hostname of the docker host and `[keyword filter]` (defaults to `node-red`) is the name of the keyword to filter the entries in the repository on.