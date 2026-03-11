# For troubleshooting reference https://docs.docker.com/guides/golang/build-images/

# Initialize GO_VERSION to 1.25.1 as default if not overridden
ARG GO_VERSION=1.25.1

# Multi-stage build:
# Smaller runtime image, safer security-wise, stripped to bare essentials of what the app needs to run

#################################
# Stage 1: Build the executable #
#################################
FROM golang:${GO_VERSION} AS builder

WORKDIR /app

# Caches dependencies, so they don't have to be redownloaded every time the code changes. Only redownloads if go.mod or go.sum change.
COPY go.mod go.sum ./
RUN go mod download

# The only file we need is SimpleWebApp.go, but if more were added, we would use COPY . .
COPY ./*.go ./

# Build the file
# CGO_ENABLED=0 is appropriate in this case, tells it not to use C code which allows for more portability and faster runtime, also ensures binary is statically linked which is necessary for distroless images
# GOOS=linux sets target operating system. Note that it can still work on Mac and Windows, but our container is Linux-based. Also note that this is the default, just included to be modifiable later
# GOARCH=amd64 sets target architecture to the cloud platform's architecture, if team would use different architectures this will need to be modified
# go build is the Go command to compile the program, -o and the path that follows are where the executable will be found
# -trimpath removes paths from the compiled executable, which can help with reproducibility and security by not including local file paths in the binary
# -ldflags="-s -w" removes symbol table and debug information, which can reduce the size of the binary and slightly improve performance, but makes debugging more difficult
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/simple-web-app .

####################
# Stage 2: Runtime #
####################
# Distroless image from google, no shell, no package manager, runs as nonroot, minimal OS use
# This makes the image smaller and more secure, but also means we can't exec into it to debug
FROM gcr.io/distroless/static-debian12:nonroot

# Cloud Run listens on $PORT, default is set to 8080
EXPOSE 8080

# Copy contains only compiled executable from the builder stage, so it is much smaller than the builder image 
COPY --from=builder /out/simple-web-app /simple-web-app

CMD ["/simple-web-app"]