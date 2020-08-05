FROM arm64v8/openjdk:11-jre-slim
LABEL maintainer='Chris Kankiewicz <Chris@ChrisKankiewicz.com>'

# Minecraft version
ARG MC_VERSION=1.16.1
ARG FABRIC_VERSION=0.6.1.45

# Set default JVM options
ENV _JAVA_OPTIONS '-Xms256M -Xmx1024M'

# Set Fabric URL
ARG FABRIC_INSTALLER_JAR_URL=https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_VERSION}/fabric-installer-${FABRIC_VERSION}.jar

# Create Minecraft directories
RUN mkdir -pv /opt/minecraft /etc/minecraft
RUN mkdir -pv /minecraft-fabric

# Create non-root user
RUN adduser --gecos "" --disabled-password --no-create-home --shell /sbin/nologin minecraft

# Add the EULA file
COPY files/eula.txt /etc/minecraft/eula.txt

# Add the ops script
COPY files/ops /usr/local/bin/ops
RUN chmod +x /usr/local/bin/ops

# Install dependencies, fetch Minecraft server jar file and chown files
RUN apt-get update && apt-get install -y ca-certificates libnss3 tzdata wget && \
    wget -O /minecraft-fabric/fabric-installer.jar ${FABRIC_INSTALLER_JAR_URL} && \
    apt-get remove -y --purge wget && rm -rf /var/lib/apt/lists/* && \
    java -jar /minecraft-fabric/fabric-installer.jar server -downloadMinecraft -mcversion ${MC_VERSION} -dir /opt/minecraft && \
    rm -r /minecraft-fabric && \
    chown -R minecraft:minecraft /etc/minecraft /opt/minecraft

# Define volumes
VOLUME /etc/minecraft

# Expose port
EXPOSE 25565

# Set running user
USER minecraft

# Set the working dir
WORKDIR /etc/minecraft

# Default run command
CMD ["java", "-jar", "/opt/minecraft/fabric-server-launch.jar", "nogui"]
