# Experiments with [App Tx Pipelines](https://github.com/vmwarepivotallabs/pcf-apptx-pipelines)

Concourse pipeline that downloads [Chachkies Application](https://github.com/poprygun/chachkies) from github, builds, uploads to artifactory, and deploys to PCF using [app tx tasks](https://github.com/vmwarepivotallabs/pcf-apptx-pipelines/tree/master/tasks).

Many thanks to Mark Alston [for inspiration](https://github.com/malston/sample-spring-cloud-svc).

## Prerequisites

- Kubernetes cluster, Docker Desktop would do.

- Install Concourse

```bash
helm install my-concourse concourse/concourse
```

Follow helm output instructions to setup port forwarding

```bash
export POD_NAME=$(kubectl get pods --namespace default -l "app=my-release-web" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:8080 to use Concourse"
kubectl port-forward --namespace default $POD_NAME 8080:8080
```    

- Install Artifactory

```bash
helm install jfrog/artifactory --version 10.0.7 --generate-name
```

LoadBalancer service created by chart does not work when cluster is running on Docker Desktop.  We can deploy our own NodePort service to expose (Artifactory UI)[http://localhost:30080/ui]

```bash
kubectl apply -f artifactory-service.yaml
```

Because of `Gotcha No 1`...  Capture Artifactory endponint and modify credentials.yaml and pom.xml with ip/port.
Figure out ClusterIP service name, and get IP from its endpoint.

```bash
kubectl get endpoints artifactory-1595519775-artifactory
```

## Deploy Pipeline

```bash
./set_pipeline.sh
```

## Gotchas

- Concourse does not seem to recognize Artifactory service if refered by name.  There are workarounds mentioned in [this thread](https://pivotal.slack.com/archives/C6TL2PMC7/p1595446475412300).

- Pipeline works with Artifactory Pro, not Arifactory OSS.  Tasks are trying to pull the jar file by using `curl`, and REST API that allows for direct access to jars is not available in OSS, so snapshot versions of jars can not be directly downloaded without specifying the timestamp suffix.

## Some Concourse commands

```bash
fly -t <APPNAME> login -c http://127.0.0.1:8080 -u test -p test
fly --target <APPNAME> set-pipeline --config ci/pipeline.yml --pipeline <PIPELINE_NAME> --load-vars-from ci/credentials.yml
fly -t <APPNAME> unpause-pipeline -p <PIPELINE_NAME>
```
