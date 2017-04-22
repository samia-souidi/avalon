require 'addressable/uri'
require 'aws-sdk'

class FileLocator
  attr_reader :source

  class S3File
    attr_reader :bucket, :key

    def initialize(uri)
      uri = Addressable::URI.parse(uri)
      @bucket = URI.decode(uri.host)
      @key = URI.decode(uri.path).sub(%r(^/*(.+)/*$),'\1')
    end

    def object
      Aws::S3::Object.new(bucket_name: bucket, key: key)
    end
  end

  def initialize(source)
    @source = source
  end

  def uri
    if @uri.nil?
      encoded_source = source
      begin
        @uri = Addressable::URI.parse(encoded_source)
      rescue URI::InvalidURIError
        if encoded_source == source
          encoded_source = URI.encode(encoded_source)
          retry
        else
          raise
        end
      end

      if @uri.scheme.nil?
        @uri = Addressable::URI.parse("file://#{URI.encode(File.expand_path(source))}")
      end
    end
    @uri
  end

  def location
    case uri.scheme
    when 's3'
      S3File.new(uri).object.presigned_url(:get)
    when 'file'
      URI.decode(uri.path)
    else
      @uri.to_s
    end
  end

  def open(&block)
    Kernel::open(location, 'r', &block)
  end
end
