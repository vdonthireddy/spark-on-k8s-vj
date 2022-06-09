#### Make sure you have [docker desktop](https://www.docker.com/products/docker-desktop/) installed on your mac and running

#### Install [brew](https://brew.sh/) if you don't already have it installed on your Mac

#### Setup a local kubernetes cluster using [kind](https://kind.sigs.k8s.io/)
```
brew install kind
```

#### Install kubectl (required to connect to kubernetes cluster)
```
brew install kubectl
```

#### Create a new kubernetes (kind) cluster
```
kind create cluster
```

#### Download apache-spark to submit spark job from your Mac
```
brew install apache-spark
```
##### *Note: Set env variable $SPARK_HOME to libexec folder (E.g. /usr/local/Cellar/apache-spark/3.2.1/libexec). If you are not sure where apache-spark is installed, run 'brew info apache-spark' to get the installation path

#### Execute the following commands in terminal to create the dashboard
```
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

k create -f ./setup.yaml
```

#### Get the token
```
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
```

#### Start the proxy to k8s APIs (in a separate terminal) and keep it running
```
kubectl proxy
```

#### Dashboard url is at:
```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```
#### Get the kubernetes master url from the following command (pay attention to the port number and use it to replace the port number in env variable: K8S_MASTER_URL
```
kubectl cluster-info
```

#### Run the following script in your terminal to submit a spark job to your cluster. You can view the result in dashboard.
```
#Use the following variables and run the commands:
IMAGE_NAME=spark-wordcount:12.0
DOCKER_APP_REPO_URL=vdonthireddy
K8S_MASTER_URL=k8s://https://127.0.0.1:65369
APP_NAME=sa-spark-driver
NUMBER_OF_EXECUTOR_INSTANCES=2
CLASS_NAME=donthireddy.vijay.WordCountVj
JAR_FILE=spark-on-k8s.jar
INPUT_FILE=USvideos.csv
K8S_AUTH_SERVICE_ACCOUNT_NAME=sa-spark-driver
K8S_NAMESPACE=spark-on-k8s
POD_NAME=sa-spark-driver
CONTAINER_NAME=sa-spark-driver-wordcount

## Uncomment the following lines if you need to push a new version of docker image to your docker hub
#cd /Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj
#mvn clean install -DskipTests=true
#docker build -t ${IMAGE_NAME} .
#docker tag ${IMAGE_NAME} ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
#docker push ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}

kubectl get pods -n ${K8S_NAMESPACE}
cd ${SPARK_HOME} && ${SPARK_HOME}/bin/spark-submit \
--master ${K8S_MASTER_URL} \
--deploy-mode cluster \
--name ${APP_NAME} \
--conf spark.executor.instances=${NUMBER_OF_EXECUTOR_INSTANCES} \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_AUTH_SERVICE_ACCOUNT_NAME} \
--conf spark.kubernetes.driver.podTemplateContainerName=${CONTAINER_NAME} \
--conf spark.kubernetes.executor.podTemplateContainerName=${CONTAINER_NAME} \
--conf spark.kubernetes.namespace=${K8S_NAMESPACE} \
--conf spark.kubernetes.container.image=${DOCKER_APP_REPO_URL}/${IMAGE_NAME} \
--class ${CLASS_NAME} \
local:///opt/spark/app-jars/${JAR_FILE} /opt/spark/app-jars/${INPUT_FILE}
```