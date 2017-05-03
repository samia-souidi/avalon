module Avalon
  module Batch
    class S3Manifest < Manifest
      class << self
        def locate(root)
          root_object = FileLocator::S3File.new(root).object
          bucket = root_object.bucket
          manifests = bucket.objects(prefix: root_object.key).select do |o|
            Manifest::EXTENSIONS.include?(File.extname(o.key).sub(/^\./,'')) && status(bucket.object(o.key)).blank?
          end
          manifests.collect { |o| "s3://#{o.bucket_name}/#{o.key}" }
        end

        def status(file)
          case file
          when Aws::S3::Object then file.metadata['batch-status']
          else FileLocator::S3File.new(file.to_s).object.metadata['batch-status']
          end
        end

        def status?(file, status)
           status(file) == status
        end
        def error?(file)      ; status?(file, 'error')      ; end
        def processing?(file) ; status?(file, 'processing') ; end
        def processed?(file)  ; status?(file, 'processed')  ; end

        def status!(file, status)
          obj = FileLocator::S3File.new(file).object
          obj.copy_to(
            bucket: obj.bucket_name,
            key: obj.key,
            content_type: obj.content_type,
            metadata: obj.metadata.merge('batch-status'=>status),
            metadata_directive: 'REPLACE'
          )
        end
      end

      def initialize(*args)
        super
      end

      def commit!   ; self.class.status!(file, 'processed')  ; end
      def error!(e) ; self.class.status!(file, 'error')      ; end
      def start!    ; self.class.status!(file, 'processing') ; end

      def path_to(f)
        FileLocator.new(file).uri.join(f).to_s
      end

      def present?(f)
        FileLocator::S3File.new(f).object.exists?
      end

      def retrieve(f)
        FileLocator::S3File.new(f).object.get.body
      end

      def attachment(f)
        return f
      end
    end
  end
end
