FROM ubuntu:20.04

# Set working directory
WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential \
    pkg-config \
    cmake \
    nlohmann-json3-dev \
    libsqlite3-dev

RUN rm -rf /var/lib/apt/lists/*

# Copy source files
COPY . .

# Build the application
RUN mkdir build && \
    cd build && \
    cmake .. && \
    make

# Expose port
EXPOSE 8000

# Run the application
CMD ["bash"]
#CMD ["./build/jokeapi"]
