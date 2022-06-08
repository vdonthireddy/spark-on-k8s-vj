#make sure you have docker desktop installed and running:
# https://docs.docker.com/desktop/mac/install/

#Create an account in docker hub:
# https://hub.docker.com/

#Execute the following commands in terminal to create the dashboard
#kind is a local kubernetes platform
brew install kind

#Install kubectl (required to connect to local kubernets)
brew install kubectl

#once kind is installed, create a cluster
kind create cluster

#download apache-spark to submit spark job from your Mac
brew install apache-spark
#set the SPARK_HOME to libexec folder (E.g. /usr/local/Cellar/apache-spark/3.2.1/libexec). If you are not sure where
# apache-spark is installed, run 'brew info apache-spark' to get the installation path

#Create the resources in k8s cluster to view the dashboard
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

#Create other resources required (like serviceaccount, role and rolebinding)
k create -f ./setup.yaml

#Get the token
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep token: | awk '{print $2}' | pbcopy

#start the proxy to k8s APIs
kubectl proxy

#dashboard url is at:
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

#Get the kubernetes master url from the following command:
kubectl cluster-info

#To build a simple java container:
DOCKER_SIMPLE_VERSION=4.0
docker rmi -f vjbox
docker build -t vjbox . -f ./Dockerfile_simple
docker run vjbox
docker tag vjbox vdonthireddy/vjbox:${DOCKER_SIMPLE_VERSION}
docker push vdonthireddy/vjbox:${DOCKER_SIMPLE_VERSION}

#To build a simple java container:
DOCKER_OBSERVER_VERSION=centos
docker rmi -f observerbox
docker build -t observerbox . -f ./Dockerfile_observer
docker run observerbox
docker tag observerbox vdonthireddy/observerbox:${DOCKER_OBSERVER_VERSION}
docker push vdonthireddy/observerbox:${DOCKER_OBSERVER_VERSION}

#Use the following variables and run the commands:
IMAGE_NAME=spark-wordcount:11.0
DOCKER_APP_REPO_URL=vdonthireddy
K8S_MASTER_URL=k8s://https://127.0.0.1:52845
APP_NAME=sa-spark-driver
NUMBER_OF_EXECUTOR_INSTANCES=2
CLASS_NAME=donthireddy.vijay.WordCountVj
JAR_FILE=spark-on-k8s.jar
INPUT_FILE=USvideos.csv
K8S_AUTH_SERVICE_ACCOUNT_NAME=sa-spark-driver
K8S_NAMESPACE=spark-on-k8s
POD_NAME=sa-spark-driver
CONTAINER_NAME=sa-spark-driver-wordcount

cd /Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj
mvn clean install -DskipTests=true
docker build -t ${IMAGE_NAME} .
docker tag ${IMAGE_NAME} ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
docker push ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}

kubectl get pods -n ${K8S_NAMESPACE}
cd ${SPARK_HOME} && ${SPARK_HOME}/bin/spark-submit \
--master ${K8S_MASTER_URL} \
--deploy-mode cluster \
--name ${APP_NAME} \
--conf spark.executor.instances=${NUMBER_OF_EXECUTOR_INSTANCES} \
--conf spark.kubernetes.driver.podTemplateFile=/Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj/pod.yaml \
--conf spark.kubernetes.executor.podTemplateFile=/Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj/pod.yaml \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_AUTH_SERVICE_ACCOUNT_NAME} \
--conf spark.kubernetes.driver.podTemplateContainerName=${CONTAINER_NAME} \
--conf spark.kubernetes.executor.podTemplateContainerName=${CONTAINER_NAME} \
--conf spark.kubernetes.namespace=${K8S_NAMESPACE} \
--conf spark.kubernetes.container.image=${DOCKER_APP_REPO_URL}/${IMAGE_NAME} \
--class ${CLASS_NAME} \
local:///opt/spark/app-jars/${JAR_FILE} /opt/spark/app-jars/${INPUT_FILE}


IMAGE_NAME=spark-wordcount:11.0
DOCKER_APP_REPO_URL=vdonthireddy
K8S_MASTER_URL=k8s://https://127.0.0.1:52845
APP_NAME=sa-spark-driver
NUMBER_OF_EXECUTOR_INSTANCES=2
CLASS_NAME=donthireddy.vijay.WordCountVj
JAR_FILE=spark-on-k8s.jar
INPUT_FILE=USvideos.csv
K8S_AUTH_SERVICE_ACCOUNT_NAME=sa-spark-driver
K8S_NAMESPACE=spark-on-k8s
POD_NAME=sa-spark-driver
CONTAINER_NAME=sa-spark-driver-wordcount

kubectl get pods -n ${K8S_NAMESPACE}
kubectl delete pod ${POD_NAME} -n ${K8S_NAMESPACE}
cd ${SPARK_HOME} && ${SPARK_HOME}/bin/spark-submit \
--master ${K8S_MASTER_URL} \
--deploy-mode cluster \
--name ${APP_NAME} \
--conf spark.executor.instances=${NUMBER_OF_EXECUTOR_INSTANCES} \
--conf spark.kubernetes.driver.pod.name=${POD_NAME} \
--conf spark.kubernetes.driver.podTemplateFile=/Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj/pod.yaml \
--conf spark.kubernetes.executor.podTemplateFile=/Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj/pod.yaml \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_AUTH_SERVICE_ACCOUNT_NAME} \
--conf spark.kubernetes.driver.podTemplateContainerName=${CONTAINER_NAME} \
--conf spark.kubernetes.executor.podTemplateContainerName=${CONTAINER_NAME} \
--conf spark.kubernetes.namespace=${K8S_NAMESPACE} \
--conf spark.kubernetes.container.image=${DOCKER_APP_REPO_URL}/${IMAGE_NAME} \
--class ${CLASS_NAME} \
local:///opt/spark/app-jars/${JAR_FILE} /opt/spark/app-jars/${INPUT_FILE}



#kubectl get pods -n ${K8S_NAMESPACE}
#cd ${SPARK_HOME} && ${SPARK_HOME}/bin/spark-submit \
#--master ${K8S_MASTER_URL} \
#--deploy-mode cluster \
#--name ${APP_NAME} \
#--conf spark.kubernetes.driver.pod.name=${POD_NAME} \
#--conf spark.executor.instances=${NUMBER_OF_EXECUTOR_INSTANCES} \
#--conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_AUTH_SERVICE_ACCOUNT_NAME} \
#--conf spark.kubernetes.namespace=${K8S_NAMESPACE} \
#--conf spark.kubernetes.container.image=${DOCKER_APP_REPO_URL}/${IMAGE_NAME} \
#--conf spark.kubernetes.driver.podTemplateFile=/Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj/pod.yaml \
#--conf spark.kubernetes.executor.podTemplateFile=/Users/donthireddy/code/spark-on-k8s-vj/spark-on-k8s-vj/pod.yaml \
#--class ${CLASS_NAME} \
#local:///opt/spark/app-jars/${JAR_FILE} /opt/spark/app-jars/${INPUT_FILE}