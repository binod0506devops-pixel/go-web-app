# Use official Go image version 1.21
# "as base" means we are naming this stage as "base"
FROM golang:1.21 as base

# Set working directory inside container to /app
# All next commands will run inside this folder
WORKDIR /app

# Copy only go.mod file from your system to container
# This file contains dependency information
COPY go.mod .

# Download all Go dependencies mentioned in go.mod
RUN go mod download

# Copy everything from your project folder to container 
# (main.go, static folder, etc.)
COPY . .

# Build the Go application
# -o main → create an output file named "main"
# "." → build the current project
RUN go build -o main .

# Comment line (for humans only)
# Final stage – Distroless image

# Start second stage using small runtime image
# This image does NOT contain Go compiler (very small & secure)
FROM gcr.io/distroless/base

# Copy compiled binary from first stage (base)
# /app/main → from builder
# . → copy into current folder inside new container
COPY --from=base /app/main .

# Copy static folder from first stage
# This is needed if your app serves HTML/CSS/JS
COPY --from=base /app/static ./static

# Inform Docker that application uses port 8080
# (This does NOT actually open the port, just documentation)
EXPOSE 8080

# This command runs when container starts
# It executes the compiled Go binary
CMD ["./main"]