# For troubleshooting reference https://docs.docker.com/guides/golang/build-images/

# Initialize GO_VERSION to 1.25.1 as default for the build process, but take .go-version number as argument later
ARG GO_VERSION=1.25.1

# Multi-stage build
# Smaller runtime image, safer security-wise, stripped to bare essentials of what the app needs to run

#################################
# Stage 1: Build the executable #
#################################
# Reads version number from .go file and uses that to build the container
# stage name: builder - allows multiple stages
FROM golang:${GO_VERSION} AS builder

# Create a directory for COPY to put things into
WORKDIR /app

# Download necessary Go modules for the app
# Caches dependencies, so they don't have to be redownloaded every time the code changes. Only redownloads if go.mod or go.sum change.
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the Go code into /app -- this version scales better than copying everything
COPY ./*.go ./

# Build the file
# CGO_ENABLED=0 is necessary for Go specifically, tells it not to use C code which allows for more portability and faster runtime
# GOOS=linux sets target operating system. Note that it can still work on Mac and Windows, but our container is Linux-based. Also note that this is the default, just included to be modifiable later
# GOARCH=amd64 sets target architecture to the cloud platform's architecture, if team would use different architectures this may need to be modified
# go build is the Go command to compile the program, -o and the path that follows are where the executable will be found
# -trimpath removes paths from the compiled executable, which can help with reproducibility and security by not including local file paths in the binary
# -ldflags="-s -w" removes symbol table and debug information, which can reduce the size of the binary and slightly improve performance, but makes debugging more difficult
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/simple-web-app .

####################
# Stage 2: Runtime #
####################
# Distroless image from google, no shell, no package manager, runs as nonroot, minimal OS use
# This makes the image smaller and more secure, but also means you can't exec into it to debug
FROM gcr.io/distroless/static-debian12:nonroot

# Cloud Run listens on $PORT, default is set to 8080
EXPOSE 8080

# Copy the executable from the builder stage into the runtime image
COPY --from=builder /out/simple-web-app /simple-web-app

# Command to run the app
CMD ["/simple-web-app"]