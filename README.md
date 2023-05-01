# Instructions

#### Step 1):
If this cluster does not have a working image registry yet, configure the registry to use an empty dir and set the
internal registry to managed:
~~~
./enable-emptydir-registry.sh
~~~

#### Step 2):
Install the kernel-module-management operator:
~~~
./install-kernel-module-management.sh
~~~

#### Step 3):
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

#### Step 4):
Build the kernel module image:
~~~
./build-kernel-module.sh
~~~
> Edit the URL and release version as needed, e.g. OCP 4.12 is based on release version 8.6

#### Step 5):
Load the kernel module:
~~~
oc apply -f load-module.yaml
~~~
> Make changes to this file as needed. For example the IS stream location.
