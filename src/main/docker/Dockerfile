FROM ubuntu:23.04 AS tool

COPY *.crt /usr/local/share/ca-certificates/

RUN echo "Update packages, install required packages and update trust store" && \
    apt-get update && \
    apt-get install --yes --no-install-recommends curl unzip ca-certificates && \
    apt-get clean && \
    update-ca-certificates

FROM tool AS maven
ARG ARG_MAVEN_VERSION=3.9.5
ARG ARG_APACHE_MIRROR_URL=https://dlcdn.apache.org
RUN echo "Download and unpack Maven binaries" && \
    mkdir -p /usr/share/maven /usr/share/maven/ref && \
    curl -fsSL -o /tmp/apache-maven.tar.gz $ARG_APACHE_MIRROR_URL/maven/maven-3/$ARG_MAVEN_VERSION/binaries/apache-maven-$ARG_MAVEN_VERSION-bin.tar.gz && \
    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1

FROM tool AS kubectl
ARG ARG_KUBECTL_VERSION=1.28.2
RUN echo "Download kubectl binary" && \
    curl -fsSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v$ARG_KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    chmod a+x /usr/local/bin/kubectl

FROM tool AS helm
ARG ARG_HELM_VERSION=3.13.0
RUN echo "Download and unpack helm binaries" && \
    curl -fsSL -o /tmp/helm-linux-amd64.tar.gz https://get.helm.sh/helm-v$ARG_HELM_VERSION-linux-amd64.tar.gz && \
    mkdir -p /tmp/helm && \
    tar -xzf /tmp/helm-linux-amd64.tar.gz -C /tmp/helm && \
    mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm && \
    chmod a+x /usr/local/bin/helm

FROM tool AS awscli
RUN echo "Download and unpack AWS CLI binaries" && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install

FROM ubuntu:23.04

ARG ARG_MAVEN_VERSION=3.9.5
ARG ARG_KUBECTL_VERSION=1.28.2
ARG ARG_HELM_VERSION=3.13.0
ARG ARG_KUBECTL_HOME=/root/.kube
ARG ARG_HELM_HOME=/root/.helm

LABEL maintainer="michael.theis@msg.group"
LABEL ${project.groupId}.${project.artifactId}.project="CloudTrain"
LABEL ${project.groupId}.${project.artifactId}.version="${project.version}"
LABEL ${project.groupId}.${project.artifactId}.description="${project.description}"
LABEL ${project.groupId}.${project.artifactId}.java.version="11.0.10_9"
LABEL ${project.groupId}.${project.artifactId}.maven.version="$ARG_MAVEN_VERSION"
LABEL ${project.groupId}.${project.artifactId}.docker.version="19.03.8"
LABEL ${project.groupId}.${project.artifactId}.kubectl.version="$ARG_KUBECTL_VERSION"
LABEL ${project.groupId}.${project.artifactId}.helm.version="$ARG_HELM_VERSION"

ENV \
# Docker Daemon options (change only if you know what you are doing!)
  DOCKERD_OPTIONS="" \
# Docker Daemon host address
  DOCKER_HOST="unix:///var/run/docker.sock" \
# Maven installation folder
  MAVEN_HOME=/opt/maven \
# Maven user settings folder
  MAVEN_CONFIG="~/.m2" \
# Set default encoding to UTF-8
  LANG=C.UTF-8 \
# kubectl configuration files
  KUBECONFIG=/root/.kube/cloudtrain-config.yaml \
# target EKS cluster name \
  AWS_EKS_CLUSTER_NAME=$ARG_EKS_CLUSTER_NAME

# copy Maven binaries from build maven
COPY --from=maven /usr/share/maven /opt/maven
# copy kubectl binaries from build kubectl
COPY --from=kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl
# copy helm binaries from build helm
COPY --from=helm /usr/local/bin/helm /usr/local/bin/helm
# copy AWS CLI binaries from build awscli
COPY --from=awscli /tmp/aws/dist /opt/aws-cli

RUN echo "Update system packages" && \
    apt-get update && \
    echo "Set system timezone" && \
    apt-get install --yes tzdata && \
    echo "Install missing tools, Java 11 JDK, Java 17 JDK and Docker via Ubuntu repository" && \
    apt-get install --yes docker.io groff openjdk-17-jdk-headless && \
    echo "Clean up after installation" && \
    apt-get clean && \
    apt-get autoremove --purge && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Install Maven" && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    echo "Install kubectl" && \
    mkdir -p $ARG_KUBECTL_HOME && \
    echo "Install helm" && \
    mkdir -p $ARG_HELM_HOME && \
    echo "Install AWS CLI v2" && \
    ln -sf /opt/aws-cli/aws /usr/local/bin/aws && \
    ln -sf /opt/aws-cli/aws_completer /usr/local/bin/aws_completer

COPY start-docker.sh /usr/bin/
COPY docker-entrypoint.sh /usr/bin/

RUN echo "Change access rights on copied shell scripts" && \
    chmod u+x /usr/bin/start-docker.sh && \
    chmod u+x /usr/bin/docker-entrypoint.sh

# Unfortunately we have to use hardcoded paths here if we want to pass arguments to the script
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
