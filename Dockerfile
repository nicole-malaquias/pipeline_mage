FROM mageai/mageai:latest
ARG PIP=pip3

# Adicionando repositório Debian Bullseye para dependências
RUN echo 'deb http://deb.debian.org/debian bullseye main' > /etc/apt/sources.list.d/bullseye.list

# Instalar OpenJDK 11 (necessário para Spark)
RUN apt-get update -y && \
    apt-get install -y openjdk-11-jdk && \
    rm -rf /var/lib/apt/lists/*

# Remover repositório Debian Bullseye
RUN rm /etc/apt/sources.list.d/bullseye.list

# Instalar PySpark e Conectores
RUN ${PIP} install --no-cache-dir pyspark \
    google-cloud-bigquery \
    pyspark \
    delta-spark

# Configurar variável de ambiente para MageAI
ENV MAGE_DATA_DIR=/home/src/mage_data

# Configurar Java para o Spark
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /home/src

CMD ["/bin/sh", "-c", "/app/run_app.sh"]
