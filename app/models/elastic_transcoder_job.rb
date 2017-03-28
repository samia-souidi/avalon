class ElasticTranscoderJob < ActiveEncode::Base
  before_create :upload_to_s3

  def upload_to_s3
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])

    file_path = self.input.sub("file://", "")
    file_name = File.basename file_path
    output_file_name = File.basename(file_name, ".*") + ".mp4"
    input_key = "#{ENV['S3_UPLOAD_PREFIX']}/#{SecureRandom.uuid}/#{file_name}"

    obj = s3.bucket(ENV['S3_BUCKET']).object input_key
    obj.upload_file file_path
  end
end
