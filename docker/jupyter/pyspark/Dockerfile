# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG PYTHON_VERSION=3.10
ARG SPARK_VERSION=3.4.1

# -----
FROM tientq/spark:${SPARK_VERSION} as spark

# -----
FROM jupyter/scipy-notebook:python-${PYTHON_VERSION}

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ARG JAVA_VERSION="17"

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    "openjdk-${JAVA_VERSION}-jre-headless" \
    ca-certificates-java \
    curl tzdata \
    # Hadoop native packages
    libbz2-1.0 liblz4-1 libsnappy1v5 zlib1g libzstd1 \
    libssl3 libisal2 libnss3 libpam-modules krb5-user procps \
    # Spark native packages
    libopenblas-base libatlas3-base libarpack2; \
    apt-get clean && rm -rf /var/lib/apt/lists/*;

# Add Spark
ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64" \
    SPARK_HOME="/opt/spark" \
    PATH="/opt/spark/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/spark/hadoop/lib/native:${LD_LIBRARY_PATH}"


COPY --link --chown=$NB_UID:$NB_GID --from=spark /opt/spark  ${SPARK_HOME}

# Configure IPython system-wide
COPY ipython_kernel_config.py "/etc/ipython/"
RUN fix-permissions "/etc/ipython/"; \
    # Add a link in the before_notebook hook in order to source automatically PYTHONPATH
    mkdir -p "/usr/local/bin/start-notebook.d"; \
    ln -s "${SPARK_HOME}/sbin/spark-config.sh" "/usr/local/bin/start-notebook.d/spark-config.sh";

USER ${NB_UID}

# Install pyarrow
# NOTE: It's important to ensure compatibility between Pandas versions.
# The pandas version in this Dockerfile should match the version
# on which the Pandas API for Spark is built.
# To find the right version:
# 1. Check out the Spark branch you are on.
# 2. Find the pandas version in the file spark/dev/infra/Dockerfile.
RUN mamba install --yes \
    'pandas<=1.5.3' \
    'pyarrow' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

WORKDIR "${HOME}"
EXPOSE 4040
