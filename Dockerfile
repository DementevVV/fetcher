FROM ruby:3.2.1-alpine

# Set working directory for the command line program
WORKDIR /app

# Copy the command line program to the container
COPY fetcher.rb .

# Set the entrypoint
ENTRYPOINT ["ruby", "fetcher.rb"]
