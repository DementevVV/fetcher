# frozen_string_literal: true

require 'fileutils'
require 'net/http'
require 'optparse'
require 'time'

# Module Fetch - for fetching web pages and recording metadata
module Fetch
  def self.run(args)
    options = parse_options(args)

    if options[:urls].empty?
      puts 'Error: At least one URL is required.'
      exit
    end

    options[:urls].each do |url|
      fetch_web_page(url, options)
    end
  end

  # Parse command-line options and return the options hash
  def self.parse_options(args)
    options = {}

    parser = OptionParser.new do |opts|
      opts.banner = 'Usage: fetch [options] url1 url2 ...'

      add_metadata_option(opts, options)
      add_save_metadata_option(opts, options)
      add_help_option(opts)
    end

    parser.parse!(args)

    options[:urls] = args

    options
  end

  # Add the metadata command-line option to the parser
  def self.add_metadata_option(opts, options)
    opts.on('-m', '--metadata', 'Record metadata of fetched website') do
      options[:metadata] = true
    end
  end

  # Add the save metadata command-line option to the parser
  def self.add_save_metadata_option(opts, options)
    opts.on('-s', '--save', 'Save metadata of fetched website') do
      options[:save_metadata] = true
    end
  end

  # Add the help command-line option to the parser
  def self.add_help_option(opts)
    opts.on('-h', '--help', 'Prints this help') do
      puts opts
      exit
    end
  end

  def self.fetch_web_page(url, options)
    uri = URI.parse(url)
    uri = URI.parse("https://#{url}") if uri.scheme.nil?

    response = Net::HTTP.get_response(uri)

    if options[:metadata]
      save_metadata(uri)
      print_metadata(uri)
    end

    delete_metadata(uri) unless options[:save_metadata]

    write_response_to_file(uri, response)
  end

  # Save metadata of fetched website
  def self.save_metadata(uri)
    last_fetched_time = File.exist?("#{uri.host}.html") ? File.stat("#{uri.host}.html").mtime : Time.now

    metadata_file = File.open("#{uri.host}.metadata", 'w')
    metadata_file.write("Website: #{uri.host}\n")
    metadata_file.write("Last fetch: #{last_fetched_time}\n")

    response_body = Net::HTTP.get(uri)
    links_count, images_count, svg_count = count_elements(response_body)
    metadata_file.write("Links count: #{links_count}\n")
    metadata_file.write("Images count: #{images_count}\n")
    metadata_file.write("SVG count: #{svg_count}\n")

    metadata_file.close
  end

  # Count links, images, and SVGs in the response body
  def self.count_elements(response_body)
    links_count = response_body.scan(/<a /).count
    images_count = response_body.scan(/<img /).count
    svg_count = response_body.scan(/<svg /).count
    [links_count, images_count, svg_count]
  end

  # Print the contents of the metadata file
  def self.print_metadata(uri)
    puts File.read("#{uri.host}.metadata")
    puts "\n"
  end

  # Delete the metadata file if it exists and if it should be deleted
  def self.delete_metadata(uri)
    File.delete("#{uri.host}.metadata") if File.exist?("#{uri.host}.metadata")
  end

  def self.write_response_to_file(uri, response)
    File.open("#{uri.host}.html", 'w') do |file|
      file.write(response.body)
    end
  end
end

Fetch.run(ARGV)
