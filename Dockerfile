FROM arm64v8/openjdk:11-jre-slim
LABEL maintainer='Chris Kankiewicz <Chris@ChrisKankiewicz.com>'

# Minecraft version
ARG MC_VERSION=1.15.2
ARG FORGE_VERSION=31.2.0

# Set jar file URL
ARG FORGE_INSTALLER_JAR_URL=https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar

# Set default JVM options
ENV _JAVA_OPTIONS '-Xms256M -Xmx1024M'

# Create Minecraft directories
RUN mkdir -pv /opt/minecraft /etc/minecraft
RUN mkdir -pv /minecraft-forge

# Create non-root user
RUN adduser --gecos "" --disabled-password --no-create-home --shell /sbin/nologin minecraft

# Add the EULA file
COPY files/eula.txt /etc/minecraft/eula.txt

# Add the ops script
COPY files/ops /usr/local/bin/ops
RUN chmod +x /usr/local/bin/ops

# Install dependencies, fetch Minecraft server jar file and chown files
RUN apt-get update && apt-get install -y ca-certificates libnss3 tzdata wget && \
    wget -O /minecraft-forge/forge-installer.jar ${FORGE_INSTALLER_JAR_URL} && \
    apt-get remove -y --purge wget && rm -rf /var/lib/apt/lists/* && \
    java -jar /minecraft-forge/forge-installer.jar --installServer /opt/minecraft && \
    rm -r /minecraft-forge && \
    mv /opt/minecraft/forge-${MC_VERSION}-${FORGE_VERSION}.jar /opt/minecraft/forge.jar && \
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
CMD ["java", "-jar", "/opt/minecraft/forge-${MC_VERSION}-${FORGE_VERSION}.jar", "nogui"]
