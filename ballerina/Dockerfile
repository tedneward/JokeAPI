FROM ballerina/ballerina:latest

WORKDIR /home/ballerina
COPY . /home/ballerina
EXPOSE 8000
# Use the CLI installed in the official image runtime path
CMD ["/ballerina/runtime/bin/bal", "run", "--offline", "joke_service.bal"]
