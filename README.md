# Multi Tenant Node-RED Kubernetes

A collection of Containers and definition files that will implement a Multi Tenant Node-RED environment on Kubernetes.

## Deprecated 

This project is now deprecated, there will be no more updates and no support for anybody triyng to use it. If you are looking for a Multi Tenant Node-RED solution I suggest you look at [FlowForge](https://flowforge.com).

## Download

```
$ git clone --recurse-submodules https://github.com/hardillb/multi-tenant-node-red-k8s.git
```

## Pre-reqs

### Creating secrets and setting domain

Running `./setup.sh` in the root directory of the project will generate a `deployment/registry-conf.yml` file that holds the details for securing the registry and and the private container registry in `settings.js` for the management app.

The script takes 2 arguments

 - The first is the root domain that will be instance names will be appended to
 - The second is the host (and optional port) for the local container repository

```
$ ./setup.sh example.com private.example.com:5000
```

### Build Containers

The Custom Node-RED, Management App and Catalogue containers need building and pushing to your local private container registry.

```
$ docker build -t private.example.com:5000/custom-node-red ./custom-node-red
...
$ docker push private.example.com:5000/custom-node-red
```
and
```
$ docker build -t private.example.com:5000/k8s-manager ./manager
...
$ docker push private.example.com:5000/k8s-manager
```
and
```
$ docker build -t private.example.com:5000/catalogue ./catalogue
...
$ docker push private.example.com:5000/catalogue
```

#### Regstiry Container

When running on a AMD64 based host everything should be fine, but if you want to run on ARM64 then you  will need to rebuild the [verdaccio/verdaccio](https://github.com/verdaccio/verdaccio) container as they only ship AMD64 versions. You will then need to modify the `deployment/deployment.yml` by hand to point to the local build on your private container registry.

```
      - name: registry
        image: private.example.com:5000/verdaccio
        ports:
        - containerPort: 4873
        volumeMounts:
        - name: registry-data
          mountPath: /verdaccio/storage
        - name: registry-conf
          mountPath: /verdaccio/conf
```


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
