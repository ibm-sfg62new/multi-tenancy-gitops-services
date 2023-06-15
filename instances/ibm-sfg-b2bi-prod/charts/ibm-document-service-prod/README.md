  # (CHARTNAME) (-Beta)
* [(PRODUCTNAME)](https://<PRODUCTURL>) is ... brief sentence regarding product
* Add "-Beta" as suffix if beta version - beta versions are generally < 1.0.0
* Don't include versions of charts or products

## Introduction
This chart ...
* Paragraph overview of the workload
* Include links to external sources for more product info
* Don't say "for xxx" - the chart should remain a general chart not directly stating target platform. 

## Chart Details
* Simple bullet list of what is deployed as the standard config
* General description of the topology of the workload 
* Keep it short and specific with items such as : ingress, services, storage, pods, statefulsets, etc. 

## Prerequisites
* See the [IBM Cloud Pak Dependency Management Guidance](https://ibm.biz/Bdfjqd) for help with this section.
* Kubernetes Level - indicate if specific APIs must be enabled (i.e. Kubernetes 1.6 with Beta APIs enabled)
* PersistentVolume requirements (if persistence.enabled) - PV provisioner support, StorageClass defined, etc. (i.e. PersistentVolume provisioner support in underlying infrastructure with ibmc-file-gold StorageClass defined if persistance.enabled=true)
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section needs to be inclusive of all / total resources of all charts and subcharts.
* Describe any custom image policy requirements if using a non-whitelisted image repository.
* 
### SecurityContextConstraints Requirements
_WRITER NOTES:  Replace the Predefined SCC Name and SCC Definition with the required values in your chart.  See [ https://ibm.biz/icppbk-psp] for help._

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined OpenShift SecurityContextConstraints name: `anyuid` has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-chart-dev-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - NET_BIND_SERVICE
    seLinux:
      type: MustRunAs
    supplementalGroups:
      type: RunAsAny
    runAsUser:
      type: RunAsAny
    fsGroup:
      rule: RunAsAny
    volumes:
    - configMap
    - secret
    ```

## Resources Required
* Describes Minimum System Resources Required

## Pre-install steps

Before installing the chart to your cluster, the cluster admin must perform the following pre-install steps.

* Create a namespace
* Create a ServiceAccount
    ```
    apiVersion: v1
    kind: ServiceAccount
    metadata: 
      name: {{ sa_name }}-nginxref-nginx
    imagePullSecrets:
    - name: sa-{{ NAMESPACE }}
    ```
* Create a RoleBinding
    ```
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: RoleBinding
    metadata: 
      name: {{ rb_name }}-rb
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: {{ role_name }}-role
    subjects:
    - kind: ServiceAccount
      name: {{ sa_name }}-nginxref-nginx
      namespace: {{ NAMESPACE }}
    ```
* Create a Role
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata: 
      name: {{ role_name }}-role
    rules: 
    - apiGroups: 
      - ""
      resources: 
      - configmaps
      verbs: 
      - get
      - watch
      - list
    ```

If you use the custom security configuration provided here, you must specify messagesight-sa as the service account for your charts.


## Installing the Chart
* Include at the basic things necessary to install the chart from the Helm CLI - the general happy path
* Include setup of other items required
* Security privileges required to deploy chart (role, SecurityContextConstraint, etc)
* Include verification of the chart 
* Ensure CLI only and avoid any product-specific language used

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release stable/<chartname>
```

The command deploys <Chart name> on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list`

* Generally teams have subsections for : 
   * Verifying the Chart
   * Uninstalling the Chart

### Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions with additional commands required for clean-up.  

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

### Cleanup any pre-reqs that were created
If cleanup scripts were included in the pak_extensions/post-delete directory; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration
* Define all the parms in the values.yaml 
* Include "how used" information
* If special configuration impacts a "set of values", call out the set of values required (a = true, y = abc_value, c = 1) to get a desired outcome. One example may be setting on multiple values to turn on or off TLS. 

The following tables lists the configurable parameters of the <CHARTNAME> chart and their default values.

| Parameter                                                                  | Description                                                                                                                                                                  | Default                                                 |
|----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| `license`                                                                  | Accept DM/SFG license                                                                                                                                                        | `fasle`                                                 |
| `replicaCount`                                                             | Number of deployment replicas                                                                                                                                                | `1`                                                     |
| `image.repository`                                                         | `PRODUCTNAME` image repository                                                                                                                                               | `nginx`                                                 |
| `image.pullPolicy`                                                         | Image pull policy                                                                                                                                                            | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `image.tag`                                                                | `PRODUCTNAME` image tag                                                                                                                                                      | `stable`                                                |
| `service.type`                                                             | k8s service type exposing ports, e.g. `NodePort`                                                                                                                             | `ClusterIP`                                             |
| `arch.amd64`                                                               | Specify weight to be used for scheduling for architecture amd64                                                                                                              | 2 - No Preference                                       |
| `arch.ppc64le`                                                             | Specify weight to be used for scheduling for architecture ppc64le                                                                                                            | 2 - No Preference                                       |
| `arch.s390x`                                                               | Specify weight to be used for scheduling for architecture s390x                                                                                                              | 2 - No Preference                                       |
| `serviceAccount.name`                                                      | Existing service account name                                                                                                                                                | `default`                                               |
| `persistence.enabled`                                                      | Enable storage access to persistent volumes                                                                                                                                  | `true`                                                  |
| `persistence.useDynamicProvisioning`                                       | Enable dynamic provisioning of persistent volumes                                                                                                                            | `false`                                                 |
| `appLogsPVC.storageClassName`                                              | Logs persistent volume storage class name                                                                                                                                    |                                                         |
| `appLogsPVC.selector.label`                                                | Logs persistent volume selector label                                                                                                                                        | `intent`                                                |
| `appLogsPVC.selector.value`                                                | Logs persistent volume selector value                                                                                                                                        | `logs`                                                  |
| `appLogsPVC.accessMode`                                                    | Logs persistent volume access mode                                                                                                                                           | `ReadWriteMany`                                         |
| `appLogsPVC.size`                                                          | Logs persistent volume storage size                                                                                                                                          | `500 Mi`                                                |
| `appLogsPVC.preDefinedLogsPVCName`                                         | Predefined logs persistent volume name                                                                                                                                       |                                                         |
| `extraPVCs`                                                                | Extra volume claims shared across all deployments                                                                                                                            |                                                         |
| `logs.enableAppLogOnConsole`                                               | Enable application logs redirection to pod console                                                                                                                           | true                                                    |
| `security.supplementalGroups`                                              | Supplemental group id to access the persistent volume                                                                                                                        | 0                                                       |
| `security.fsGroup`                                                         | File system group id to access the persistent volume                                                                                                                         | 0                                                       |
| `security.runAsUser`                                                       | The User ID that needs to be run as by all containers                                                                                                                        |                                                         |
| `security.runAsGroup`                                                      | The Group ID that needs to be run as by all containers                                                                                                                       |                                                         |
| `livenessProbe.initialDelaySeconds`                                        | Livenessprobe initial delay in seconds                                                                                                                                       | 60                                                      |
| `livenessProbe.timeoutSeconds`                                             | Livenessprobe timeout in seconds                                                                                                                                             | 30                                                      |
| `livenessProbe.periodSeconds`                                              | Livenessprobe interval in seconds                                                                                                                                            | 60                                                      |
| `readinessProbe.initialDelaySeconds`                                       | ReadinessProbe initial delay in seconds                                                                                                                                      | 60                                                      |
| `readinessProbe.timeoutSeconds`                                            | ReadinessProbe timeout in seconds                                                                                                                                            | 5                                                       |
| `readinessProbe.periodSeconds`                                             | ReadinessProbe interval in seconds                                                                                                                                           | 60                                                      |
| `service.type`                                                             | Service type                                                                                                                                                                 | ClusterIP                                               |
| `service.externalport`                                                     | Service external port                                                                                                                                                        | 80                                                      |
| `service.externalPort`                                                     | External TCP Port for this service                                                                                                                                           | `80`                                                    |
| `ingress.enabled`                                                          | Ingress enabled                                                                                                                                                              | `false`                                                 |
| `ingress.hosts`                                                            | Host to route requests based on                                                                                                                                              | `false`                                                 |
| `ingress.annotations`                                                      | Meta data to drive ingress class used, etc.                                                                                                                                  | `nil`                                                   |
| `ingress.tls`                                                              | TLS secret to secure channel from client / host                                                                                                                              | `nil`                                                   |
| `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".                                                                           |                                                         |
| `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".                                                                          |                                                         |
| `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".                                                                            |                                                         |
| `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".                                                                           |                                                         |
| `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".                                                                        |                                                         |
| `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".                                                                       |                                                         |
| `topologySpreadConstraints`                                                | Topology spread constraints to control how Pods are spread across your cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. |                                                         |
| `tolerations`                                                              | Tolerations to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints                                                                     |                                                         |
| `autoscaling.enabled`                                                      | Enable autoscaling                                                                                                                                                           | false                                                   |
| `autoscaling.minReplicas`                                                  | Minimum replicas for autoscaling                                                                                                                                             | 1                                                       |
| `autoscaling.maxReplicas`                                                  | Maximum replicas for autoscaling                                                                                                                                             | 2                                                       |
| `autoscaling.targetCPUUtilizationPercentage`                               | Target CPU utilization                                                                                                                                                       | 60                                                      |
| `resources.requests.memory`                                                | Memory resource requests                                                                                                                                                     | `128Mi`                                                 |
| `resources.requests.cpu`                                                   | CPU resource requests                                                                                                                                                        | `100m'                                                  |
| `resources.limits.memory`                                                  | Memory resource limits                                                                                                                                                       | `128Mi`                                                 |
| `resources.limits.cpu`                                                     | CPU resource limits                                                                                                                                                          | `100m`                                                  |
| `application.server.port`                                                  | Port for application server                                                                                                                                                  | 8043                                                    |
| `application.server.jetty.acceptors`                                       | jetty application server acceptors                                                                                                                                           | 10                                                      |
| `application.server.jetty.maxHttpPostSize`                                 | jetty server max http port size                                                                                                                                              | 0                                                       |
| `application.server.jetty.selectors`                                       | jetty server selectors                                                                                                                                                       | 10                                                      |
| `application.server.ssl.enabled`                                           | enable the https for DM                                                                                                                                                      | true                                                    |
| `application.server.ssl.tlsSecretName`                                     | OCP tsl secret name same use in b2bi                                                                                                                                         |                                                         |
| `application.server.ssl.trustStoreType`                                    | Type of the trust store                                                                                                                                                      | PKCS12                                                  |
| `application.server.ssl.trustStoreSecretName`                              | Trust store secrete name                                                                                                                                                     |                                                         |
| `application.server.ssl.clientAuth`                                        | Type of the client auth                                                                                                                                                      | want                                                    |
| `application.server.ssl.ciphers`                                           | Ssl server ciphers                                                                                                                                                           |                                                         |
| `application.logging.level`                                                | Type of the logging                                                                                                                                                          | ERROR                                                   |
| `application.logging.rolloverSize`                                         | Logging type rollover size                                                                                                                                                   | 10MB                                                    |
| `application.logging.numberOfFiles`                                        | Logging number of files                                                                                                                                                      | 20                                                      |
| `application.spring.servlet.multipartMaxRequestSize`                       | Total request size for a multipart/form-data cannot exceed                                                                                                                   | 1MB                                                     |
| `application.spring.servlet.multipartMaxFileSize`                          | Specifies the maximum size permitted for uploaded files                                                                                                                      | 1MB                                                     |
| `application.jvmOptions`                                                   | OtherJVM options                                                                                                                                                             |                                                         |
| `objectstore.name`                                                         | Name of the object store                                                                                                                                                     | IBM Cloud                                               |
| `objectstore.classname`                                                    | Class name based on Name of object store                                                                                                                                     | com.precisely.s3sdkapi.S3ObjectStore                    |
| `objectstore.endpoint`                                                     | Endpoint of the cloud provider                                                                                                                                               | https://s3.jp-tok.cloud-object-storage.appdomain.cloud/ |
| `objectstore.port`                                                         | Port number which is using by cloud provider connection                                                                                                                      | 1                                                       |
| `objectstore.namespace`                                                    | Namespace which created on could for storing the files                                                                                                                       | man-test-dm                                             |
| `objectstore.region`                                                       | Region where namespace created                                                                                                                                               | jp-tok                                                  |
| `objectstore.accountName`                                                  | Name of the account holder                                                                                                                                                   |                                                         |
| `objectstore.secretName`                                                   | Secret key of account which want to connect                                                                                                                                  |                                                         |
| `objectstore.filePrefix`                                                   | Object store file prefix                                                                                                                                                     | doc                                                     |
| `objectstore.fileSuffix`                                                   | Object store file suffix                                                                                                                                                     | files                                                   |
| `objectstore.filePartSize`                                                 | Object store file part size                                                                                                                                                  | 104857600                                               |
| `objectstore.partBufferSize`                                               | Object store file buffer size                                                                                                                                                | 10240                                                   |
| `objectstore.serverSideEncryption`                                         | Enable the server side encryption                                                                                                                                            | false                                                   |
| `objectstore.useKeysFromSecrets`                                           | User secret key for server side encryption                                                                                                                                   | true                                                    |
| `objectstore.sslEnabled`                                                   | Client certificate enable for DM                                                                                                                                             | true                                                    |
| `objectstore.proxyRequired`                                                | Object store server required any proxy                                                                                                                                       | false                                                   |
| `objectstore.proxyHost`                                                    | Object store proxy server host                                                                                                                                               |                                                         |
| `objectstore.proxyPort`                                                    | Object store proxy server port                                                                                                                                               | 0                                                       |
| `objectstore.proxyCredentialRequired`                                      | Object store Credential required                                                                                                                                             | false                                                   |
| `objectstore.proxyUsername`                                                | Proxy server user name                                                                                                                                                       |                                                         |
| `objectstore.proxyPasswordSecretName`                                      | Proxy Server password                                                                                                                                                        |                                                         |
| `objectstore.poolSizeTransferMgr`                                          | Proxy Server Transfer manager                                                                                                                                                | 150                                                     |
| `objectstore.connectionTimeout`                                            | Object store connection timeout                                                                                                                                              | 600                                                     |
| `objectstore.readTimeout`                                                  | Object Store read time out                                                                                                                                                   | 600                                                     |
| `dashboard.enabled`                                                        | Enable automatic load of grafana dashboard                                                                                                                                   | `true`                                                  |


A subset of the above parameters map to the env variables defined in [(PRODUCTNAME)](PRODUCTDOCKERURL). For more information please refer to the [(PRODUCTNAME)](PRODUCTDOCKERURL) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Storage
* Define how storage works with the workload
* Dynamic vs PV pre-created
* Considerations if using hostpath, local volume, empty dir
* Loss of data considerations
* Any special quality of service or security needs for storage

## Limitations
* Deployment limits - can you deploy more than once, can you deploy into different namespace
* List specific limitations such as platforms, security, replica's, scaling, upgrades etc.. - noteworthy limits identified
* List deployment limitations such as : restrictions on deploying more than once or into custom namespaces. 
* Not intended to provide chart nuances, but more a state of what is supported and not - key items in simple bullet form.
* Does it work on ROKS or  ?

## Documentation
* Can have as many supporting links as necessary for this specific workload however don't overload the consumer with unnecessary information.
* Can be links to special procedures in the knowledge center.
