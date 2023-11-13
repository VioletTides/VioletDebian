FROM debian:latest

# Install any dependencies your script might have
RUN apt-get update

# Copy your script and any other necessary files
COPY ../scripts/script.sh /usr/local/bin/

# Make your script executable
RUN chmod +x /usr/local/bin/script.sh

# Set the entry point
ENTRYPOINT ["/usr/local/bin/script.sh"]

