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
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token

#start the proxy to k8s APIs
kubectl proxy

#dashboard url is at:
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

#Get the kubernetes master url from the following command:
kubectl cluster-info

#Use the following variables and run the commands:
IMAGE_NAME=spark-wordcount:4.0
DOCKER_APP_REPO_URL=vdonthireddy
K8S_MASTER_URL=k8s://https://127.0.0.1:52845
APP_NAME=spark-wordcount
NUMBER_OF_EXECUTOR_INSTANCES=2
CLASS_NAME=com.niharsystems.WordCountVj
JAR_FILE=spark-on-k8s.jar
INPUT_FILE=USvideos.csv
K8S_AUTH_SERVICE_ACCOUNT_NAME=sa-spark-driver
K8S_NAMESPACE=spark-on-k8s

docker build -t ${IMAGE_NAME} .
docker tag ${IMAGE_NAME} ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
docker push ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}

kubectl get pods
cd ${SPARK_HOME} && ${SPARK_HOME}/bin/spark-submit \
--master ${K8S_MASTER_URL} \
--deploy-mode cluster \
--name ${APP_NAME} \
--conf spark.executor.instances=${NUMBER_OF_EXECUTOR_INSTANCES} \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_AUTH_SERVICE_ACCOUNT_NAME} \
--conf spark.kubernetes.namespace=${K8S_NAMESPACE} \
--conf spark.kubernetes.container.image=${DOCKER_APP_REPO_URL}/${IMAGE_NAME} \
--class ${CLASS_NAME} \
local:///opt/spark/app-jars/${JAR_FILE} /opt/spark/app-jars/${INPUT_FILE}