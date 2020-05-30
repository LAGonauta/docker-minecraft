FROM arm64v8/openjdk:11-jre-slim
LABEL maintainer='Chris Kankiewicz <Chris@ChrisKankiewicz.com>'

# Minecraft version
ARG MC_VERSION=1.15.2
ARG MC_JAR_SHA1=bb2b6b1aefcd70dfd1892149ac3a215f6c636b07

# Set jar file URL
ARG JAR_URL=https://launcher.mojang.com/v1/objects/${MC_JAR_SHA1}/server.jar

# Set default JVM options
ENV _JAVA_OPTIONS '-Xms256M -Xmx1024M'

# Create Minecraft directories
RUN mkdir -pv /opt/minecraft /etc/minecraft

# Create non-root user
RUN adduser --gecos "" --disabled-password --no-create-home --shell /sbin/nologin minecraft

# Add the EULA file
COPY files/eula.txt /etc/minecraft/eula.txt

# Add the ops script
COPY files/ops /usr/local/bin/ops
RUN chmod +x /usr/local/bin/ops

# Install dependencies, fetch Minecraft server jar file and chown files
RUN apt-get update && apt-get install -y ca-certificates libnss3 tzdata wget && \
    wget -O /opt/minecraft/minecraft_server.jar ${JAR_URL} && \
    apt-get remove -y --purge wget && rm -rf /var/lib/apt/lists/* && \
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
CMD ["java", "-jar", "/opt/minecraft/minecraft_server.jar", "nogui"]
