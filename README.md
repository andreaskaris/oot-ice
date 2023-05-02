# Disclaimer

The below steps are experimental and not to be used in a production environment.

# Instructions

#### Step 1):
If this cluster does not have a working image registry yet, configure the registry to use an empty dir and set the
internal registry to managed:
~~~
./enable-emptydir-registry.sh
~~~

#### Step 2):
Create a new project:
~~~
oc new-project build-driver
~~~

And make it privileged:
~~~
oc adm policy add-scc-to-user privileged -z default
~~~

~~~
privileged ()
{ 
    oc label ns $1 security.openshift.io/scc.podSecurityLabelSync="false" --overwrite=true;
    oc label ns $1 pod-security.kubernetes.io/enforce=privileged --overwrite=true;
    oc label ns $1 pod-security.kubernetes.io/warn=privileged --overwrite=true;
    oc label ns $1 pod-security.kubernetes.io/audit=privileged --overwrite=true
}
privileged build-driver
~~~

#### Step 3):
Build the kernel module image:
~~~
./build-kernel-module.sh
~~~
> Edit the URL and release version as needed, e.g. OCP 4.12 is based on release version 8.6

#### Step 4):
Load the image to all nodes:
~~~
oc apply -f daemonset.yaml
~~~
> **Note:** This is a workaround as podman pull does not have the credentials to directly pull from the internal registry.

#### Step 5):
Deploy the MachineConfig that will load the kernel module on system boot:
~~~
oc apply -f machine-config.yaml
~~~
> Customize this as needed, the default file contains both master and worker machine configurations.
