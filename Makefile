IMAGE_NAME=spark-wordcount:4.0
DOCKER_APP_REPO_URL=vdonthireddy
K8S_MASTER_URL=k8s://https://127.0.0.1:52845
APP_NAME=spark-wordcount
NUMBER_OF_EXECUTOR_INSTANCES=2
CLASS_NAME=donthireddy.vijay.WordCountVj
JAR_FILE=spark-on-k8s.jar
INPUT_FILE=USvideos.csv
K8S_AUTH_SERVICE_ACCOUNT_NAME=sa-spark-driver
K8S_NAMESPACE=spark-on-k8s

build:
    docker build -t ${IMAGE_NAME} .
    docker tag ${IMAGE_NAME} ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
    docker push ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}

submit:
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



# VERSION=2022-03-14-1140
# JAR_PATH=/Users/donthireddy/.m2/repository/com/niharsystems/spark-on-k8s-vj/1.0.0-SNAPSHOT/spark-on-k8s-vj-1.0.0-SNAPSHOT-jar-with-dependencies.jar
# JAR_FILE=spark-on-ethos-vj.jar
# INPUT_PATH=/Users/donthireddy/code/spark-on-ethos-vj/src/main/resources/USvideos.csv
# INPUT_FILE=USvideos.csv
# APP_NAME=spark-on-k8s-vj
# CLASS_NAME=WordCountVj
#
# DOCKER_FILE_PATH=${SPARK_HOME}/kubernetes/dockerfiles/spark/Dockerfile_Marketo
# IMAGE_NAME=spark-on-k8s-vj:${VERSION}
#
# K8S_MASTER_URL=k8s://https://a.b.c:443
# K8S_AUTH_SERVICE_ACCOUNT_NAME=sa-spark-driver
# NUMBER_OF_EXECUTOR_INSTANCES=2
#
# all: build package submit
#
# build:
# 	mvn clean install -DskipTests
#
# package:
# 	cd ${SPARK_HOME} && mkdir -p ./niharsystems/jars
# 	cd ${SPARK_HOME}/niharsystems/jars && cp ${JAR_PATH} ${JAR_FILE}
# 	cd ${SPARK_HOME}/niharsystems/jars && cp ${INPUT_PATH} ${INPUT_FILE}
# 	cd ${SPARK_HOME}/niharsystems/jars && chmod a+x ${JAR_FILE}
# 	cd ${SPARK_HOME}/niharsystems/jars && chmod a+r ${INPUT_FILE}
#
# 	docker login -u ${ARTIFACTORY_USER} -p ${ARTIFACTORY_API_TOKEN} ${DOCKER_ASR_REPO_URL}
# 	cd ${SPARK_HOME} && docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE_PATH} .
# 	docker tag ${IMAGE_NAME} ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
# 	docker push ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
#
# submit:
# 	kubectl get pods
# 	kubectl delete pods -l name=${DRIVER_POD_LABEL_NAME}
# 	cd ${SPARK_HOME} && ${SPARK_HOME}/bin/spark-submit \
# 	--master ${K8S_MASTER_URL} \
# 	--deploy-mode cluster \
# 	--name ${APP_NAME} \
# 	--conf spark.kubernetes.context=${K8S_CONTEXT} \
# 	--conf spark.executor.instances=${NUMBER_OF_EXECUTOR_INSTANCES} \
# 	--conf spark.kubernetes.container.image=${DOCKER_APP_REPO_URL}/${IMAGE_NAME} \
# 	--conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_AUTH_SERVICE_ACCOUNT_NAME} \
# 	--conf spark.kubernetes.container.image.pullSecrets=${DOCKER_APP_REPO_URL} \
# 	--conf spark.kubernetes.namespace=${K8S_NAMESPACE} \
# 	--conf spark.kubernetes.driver.podTemplateFile=/usr/local/Cellar/apache-spark/3.1.2/libexec/examples/templates/pod.yaml \
# 	--conf spark.kubernetes.executor.podTemplateFile=/usr/local/Cellar/apache-spark/3.1.2/libexec/examples/templates/pod.yaml \
# 	--class ${CLASS_NAME} \
# 	local:///opt/spark/marketo/jars/${JAR_FILE} /opt/spark/marketo/jars/${INPUT_FILE}
#
#
#
#
# # VERSION=2022-05-09-1405
# # JAR_PATH=/Users/vijaydonthireddy/.m2/repository/com/adobe/marketo/marketo-spark-on-ethos-vj/1.0-SNAPSHOT/marketo-spark-on-ethos-vj-1.0-SNAPSHOT-jar-with-dependencies.jar
# # JAR_FILE=marketo-spark-on-ethos-vj.jar #This is how the file is renamed and copied to containers
# # INPUT_PATH=/Users/vijaydonthireddy/work/mygit/spark-on-ethos-poc/marketo-spark-on-ethos-vj/src/main/resources/USvideos.csv
# # INPUT_FILE=USvideos.csv
# # APP_NAME=marketo-spark-on-ethos-vj
# # CLASS_NAME=WordCountVj
# #
# # DOCKER_ASR_REPO_URL=docker-asr-release.dr-uw2.adobeitc.com
# # DOCKER_APP_REPO_URL=docker-vdonthireddy-snapshot.dr-uw2.adobeitc.com
# # DOCKER_FILE_PATH=${SPARK_HOME}/kubernetes/dockerfiles/spark/Dockerfile_Marketo
# # IMAGE_NAME=marketo-spark-on-ethos-vj:${VERSION}
# #
# # K8S_MASTER_URL=k8s://https://ethos11-stage-or2.ethos.adobe.net:443
# # K8S_NAMESPACE=ns-team-marketo-cloud
# # K8S_AUTH_SERVICE_ACCOUNT_NAME=sa-spark-vj
# # K8S_CONTEXT=ethos11stageor2
# # DRIVER_POD_LABEL_NAME=marketo-spark-on-ethos-vj
# # NUMBER_OF_EXECUTOR_INSTANCES=2
# #
# # all: build package submit
# # push: package submit
# #
# # build:
# # 	mvn clean install -DskipTests
# #
# # package:
# # 	cd ${SPARK_HOME} && mkdir -p ./marketo/jars
# # 	cd ${SPARK_HOME}/marketo/jars && cp ${JAR_PATH} ${JAR_FILE}
# # 	cd ${SPARK_HOME}/marketo/jars && cp ${INPUT_PATH} ${INPUT_FILE}
# # 	cd ${SPARK_HOME}/marketo/jars && chmod a+x ${JAR_FILE}
# # 	cd ${SPARK_HOME}/marketo/jars && chmod a+r ${INPUT_FILE}
# #
# # 	# Login to artifactory so that you can download the Blessed Based Container needed in Dockerfile
# # 	docker login -u ${ARTIFACTORY_USER} -p ${ARTIFACTORY_API_TOKEN} ${DOCKER_ASR_REPO_URL}
# #
# # 	# Build the docker image that contains the application jar
# # 	cd ${SPARK_HOME} && docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE_PATH} .
# # 	docker tag ${IMAGE_NAME} ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
# #
# # 	# Login to artifactory where this image will be pushed to
# # 	docker login -u ${ARTIFACTORY_USER} -p ${ARTIFACTORY_API_TOKEN} ${DOCKER_APP_REPO_URL}
# # 	docker push ${DOCKER_APP_REPO_URL}/${IMAGE_NAME}
# #
# # submit:
# # 	kubectl get pods
# # 	kubectl delete pods -l name=${DRIVER_POD_LABEL_NAME}
# # 	cd ${SPARK_HOME} && ${SPARK_HOME}/bin/spark-submit \
# # 	--master ${K8S_MASTER_URL} \
# # 	--deploy-mode cluster \
# # 	--name ${APP_NAME} \
# # 	--conf spark.kubernetes.context=${K8S_CONTEXT} \
# # 	--conf spark.executor.instances=${NUMBER_OF_EXECUTOR_INSTANCES} \
# # 	--conf spark.kubernetes.container.image=${DOCKER_APP_REPO_URL}/${IMAGE_NAME} \
# # 	--conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_AUTH_SERVICE_ACCOUNT_NAME} \
# # 	--conf spark.kubernetes.namespace=${K8S_NAMESPACE} \
# # 	--conf spark.kubernetes.driver.podTemplateFile=/usr/local/Cellar/apache-spark/3.1.2/libexec/examples/templates/pod.yaml \
# # 	--conf spark.kubernetes.executor.podTemplateFile=/usr/local/Cellar/apache-spark/3.1.2/libexec/examples/templates/pod.yaml \
# # 	--class ${CLASS_NAME} \
# # 	local:///opt/spark/marketo/jars/${JAR_FILE} /opt/spark/marketo/jars/${INPUT_FILE}
# #
# #
# #
# # #old:
# # #	--conf spark.kubernetes.container.image.pullSecrets=${DOCKER_APP_REPO_URL} \