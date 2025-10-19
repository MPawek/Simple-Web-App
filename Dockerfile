# For troubleshooting reference https://docs.docker.com/guides/golang/build-images/
# Give the language the code is in
FROM golang:1.25.3-slim

# Create a directory for COPY to put things into
WORKDIR /app

# Download necessary Go modules for the app
COPY go.mod go.sum ./
RUN go mod download

# Copy the Go source code, slash at the end is necessary for syntax reasons
COPY *.go ./

# Build the file
# CGO_ENABLED=0 is necessary for Go specifically, tells it not to use C code which allows for more portability
# GOOS=linux sets target operating system. Note that it can still work on Mac and Windows, but our container is Linux-based. Also note that this is the default, just included to be modifiable later
# go build is the Go command to compile the program, -o and the path that follows are where the executable will be found
RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-simple-web-app

# Command to run the app
CMD ["/docker-simple-web-app"]