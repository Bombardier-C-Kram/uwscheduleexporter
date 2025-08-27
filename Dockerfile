FROM dyalog/techpreview:20.0

# Install curl for health checks
USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project configuration first for better caching
COPY cider.config .
COPY deps/ ./deps/

# Copy APL source files
COPY APLSource/ ./APLSource/
COPY start.apls .
COPY activate.apls .
RUN chmod +x start.apls
RUN dyalogscript activate.apls

# Expose port 8080 for the web server
EXPOSE 8080

# Health check to verify the web server is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Set the default command
ENTRYPOINT ["/bin/env", "dyalogscript", "/app/start.apls"]
