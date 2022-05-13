FROM spark-base:1.0
COPY target/spark-on-k8s-vj-1.0.0-SNAPSHOT-jar-with-dependencies.jar /opt/spark/app-jars/spark-on-k8s.jar
COPY src/main/resources/USvideos.csv /opt/spark/app-jars/USvideos.csv
