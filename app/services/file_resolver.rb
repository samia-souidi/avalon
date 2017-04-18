require 'aws-sdk'

class FileResolver
  attr_reader :source

  class S3File
    attr_reader :bucket, :key

    def initialize(uri)
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
      @uri = URI.parse(source)
      if @uri.scheme.nil?
        @uri = URI.parse("file://#{File.expand_path(source)}")
      end
    end
    @uri
  end

  def access_uri
    case uri.scheme
    when 's3'
      S3File.new(uri).object.presigned_url(:get)
    else
      @uri.to_s
    end
  end

  def open(&block)
    case uri.scheme
    when 'file'
      Kernel::open(uri.path, 'r', &block)
    else
      Kernel::open(access_uri, &block)
    end
  end
end
