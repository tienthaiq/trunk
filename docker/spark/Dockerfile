# Common args
ARG APACHE_DIST=https://dlcdn.apache.org
ARG MAVEN_DIST=https://repo1.maven.org/maven2

# ======================
# STAGE: DOWNLOADER
# ======================
FROM alpine:3.18 AS downloader

RUN apk add -U curl gpg gpg-agent tar
WORKDIR /downloads

# =====================
# STAGE: DOWNLOAD SPARK
# =====================
FROM downloader as spark-downloader

ARG APACHE_DIST
ARG MAVEN_DIST
ARG SPARK_VERSION=3.4.1
ARG SCALA_VERSION=2.13
ARG HADOOP_MAJOR=3

RUN set -eux; \
    curl -L "${APACHE_DIST}/spark/KEYS" | gpg --import; \
    curl -LO "${APACHE_DIST}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR}.tgz" \
    curl -L "${APACHE_DIST}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR}.tgz.asc" \
    | gpg --verify - "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR}.tgz"; \
    mkdir -p /build/spark; \
    tar -zxf "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR}.tgz" --no-same-owner; \
    mv "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR}" "spark";

# * guava: https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/spark-docker/Dockerfile
#   -> Spark 3.5.0 uses guava v32.0.1: https://github.com/apache/spark/pull/41581
# * spark-hadoop-cloud: https://spark.apache.org/docs/latest/cloud-integration.html
RUN set -eux; cd "spark/jars"; \
    rm guava-*.jar; \
    curl -LO "${MAVEN_DIST}/com/google/guava/guava/32.1.2-jre/guava-32.1.2-jre.jar"; \
    curl -LO "${MAVEN_DIST}/org/apache/spark/spark-hadoop-cloud_${SCALA_VERSION}/${SPARK_VERSION}/spark-hadoop-cloud_${SCALA_VERSION}-${SPARK_VERSION}.jar"

# ======================
# STAGE: DOWNLOAD HADOOP
# ======================
FROM downloader as hadoop-downloader

ARG APACHE_DIST
ARG MAVEN_DIST
ARG HADOOP_VERSION=3.3.4

# Hadoop
# Hadoop tools: aws
RUN set -eux; \
    mkdir -p "hadoop/lib/tools" && cd "hadoop/lib/tools"; \
    curl -LO "${MAVEN_DIST}/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar"; \
    curl -LO "${MAVEN_DIST}/com/amazonaws/aws-java-sdk-bundle/1.12.560/aws-java-sdk-bundle-1.12.560.jar";
# Hadoop native libaries
RUN set -eux; \
    curl -L  "${APACHE_DIST}/hadoop/common/KEYS" | gpg --batch --import -; \
    curl -LO "${APACHE_DIST}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"; \
    curl -L  "${APACHE_DIST}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc" \
        | gpg --batch --verify - "hadoop-${HADOOP_VERSION}.tar.gz";
RUN tar -xvf  "hadoop-${HADOOP_VERSION}.tar.gz" --no-same-owner "hadoop-${HADOOP_VERSION}/lib/native"; \
    mv "hadoop-${HADOOP_VERSION}/lib/native" "hadoop/lib/native";

# ======================
# STAGE: DOWNLOAD TOOLS
# ======================
FROM downloader as tool-downloader

ARG MAVEN_DIST
ARG SPARK_MAJOR_MINOR=3.4
ARG HUDI_VERSION=0.14.0

# Tools
RUN set -eux; \
    # JDBC drivers
    curl -LO "${MAVEN_DIST}/org/postgresql/postgresql/42.6.0/postgresql-42.6.0.jar"; \
    curl -LO "${MAVEN_DIST}/com/mysql/mysql-connector-j/8.1.0/mysql-connector-j-8.1.0.jar"; \
    # Apache Hudi & tools
    curl -LO "${MAVEN_DIST}/org/apache/hudi/hudi-spark${SPARK_MAJOR_MINOR}-bundle_2.12/${HUDI_VERSION}/hudi-spark${SPARK_MAJOR_MINOR}-bundle_2.12-${HUDI_VERSION}.jar"; \
    curl -LO "${MAVEN_DIST}/org/apache/hudi/hudi-utilities-bundle_2.12/0.14.0/hudi-utilities-bundle_2.12-0.14.0.jar";

# ===========
# STAGE: MAIN
# ===========
FROM ubuntu:jammy
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG MAVEN_DIST
ARG JAVA_VERSION=17
ARG PYTHON_VERSION=3.10
ARG SPARK_MAJOR_MINOR=3.4
ARG HUDI_VERSION=0.14.0

# Based on Spark Kubernetes Dockerfile.
# Link: https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/Dockerfile
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        openjdk-${JAVA_VERSION}-jre-headless ca-certificates tzdata tini net-tools curl \
        # Hadoop native packages: https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/NativeLibraries.html
        libbz2-1.0 liblz4-1 libsnappy1v5 zlib1g libzstd1 \
        libssl3 libisal2 libnss3 krb5-user procps \
        # Spark native packages
        libopenblas-base libatlas3-base libarpack2; \
    # Python
    apt install -y --no-install-recommends \
        python${PYTHON_VERSION} python3-pip; \
    pip3 install --upgrade pip setuptools wheel; \
    rm -rf /root/.cache && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*;

RUN echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su; \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd;
    
ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64" \
    SPARK_HOME="/opt/spark" \
    # https://spark.apache.org/docs/latest/ml-linalg-guide.html#spark-configuration
    OPENBLAS_NUM_THREADS=1 \
    MKL_NUM_THREADS=1 \
    PYTHON_PATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib:${PYTHON_PATH}"

COPY --link --from=spark-downloader /downloads/spark  ${SPARK_HOME}
# TODO: put tools in separate folders
COPY --link --from=hadoop-downloader /downloads/hadoop/lib/native ${SPARK_HOME}/hadoop/lib/native
COPY --link --from=hadoop-downloader /downloads/hadoop/lib/tools/* ${SPARK_HOME}/jars/
COPY --link --from=tool-downloader /downloads/*.jar ${SPARK_HOME}/jars

ENV PATH="${SPARK_HOME}/bin:${PATH}" \
    LD_LIBRARY_PATH="${SPARK_HOME}/hadoop/lib/native:${LD_LIBRARY_PATH}"

RUN echo "" > /java_opts.txt; \
    chown 185:root /java_opts.txt;

USER 185

ENTRYPOINT [ "/opt/spark/kubernetes/dockerfiles/spark/entrypoint.sh" ]
