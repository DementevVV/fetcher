# frozen_string_literal: true

require 'minitest/autorun'
require 'open3'

# Tests for the Fetcher
class FetcherTest < Minitest::Test
  def est_fetch_web_page_without_urls
    stdout, stderr, status = Open3.capture3('ruby', 'fetcher.rb')
    assert_match(/Error: At least one URL is required./, stdout.strip)
    assert_equal '', stderr.strip
    assert_equal 0, status.exitstatus
  end

  def test_fetch_web_page
    url = 'example.com'
    _, stderr, status = Open3.capture3('ruby', 'fetcher.rb', url)
    assert File.exist?("#{url}.html")
    assert_equal '', stderr.strip
    assert_equal 0, status.exitstatus
  end

  def test_fetch_web_page_add_help_option
    stdout, stderr, status = Open3.capture3('ruby', 'fetcher.rb', '-h')
    assert_includes stdout, 'Record metadata of fetched website'
    assert_includes stdout, 'Save metadata of fetched website'
    assert_equal '', stderr
    assert_equal 0, status.exitstatus
  end

  def test_fetch_web_page_add_metadata_option
    url = 'example.com'
    stdout, stderr, status = Open3.capture3('ruby', 'fetcher.rb', '-m', url)
    assert_includes stdout, "Website: #{url}"
    assert_equal '', stderr
    assert_equal 0, status.exitstatus
    assert File.exist?("#{url}.html")
  end

  def test_fetch_web_page_add_save_metadata_option
    url = 'example.com'
    stdout, stderr, status = Open3.capture3('ruby', 'fetcher.rb', '-m', '-s', url)
    assert_includes stdout, "Website: #{url}"
    assert_equal '', stderr
    assert File.exist?("#{url}.html")
    assert File.exist?("#{url}.metadata")
    assert_equal 0, status.exitstatus
  end

  def test_invalid_url
    url = 'invalid-url'
    stdout, _, status = Open3.capture3('ruby', 'fetcher.rb', url)

    assert_includes stdout, "Error: Could not fetch website: #{url}"
    refute File.exist?("#{url}.html")
    refute File.exist?("#{url}.metadata")
    assert_equal 0, status.exitstatus
  end
end
