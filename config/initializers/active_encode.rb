require 'aws-sdk'

ActiveEncode::Base.engine_adapter = Settings.encoding.engine_adapter.to_sym
case Settings.encoding.engine_adapter.to_sym
when :matterhorn
  Rubyhorn.init
when :elastic_transcoder
  MasterFile.default_encoder_class = ElasticTranscoderJob
  pipeline = Aws::ElasticTranscoder::Client.new.read_pipeline(id: Settings.encoding.pipeline)
  # Set environment variables to guard against reloads
  ENV['SETTINGS__ENCODING__MASTERFILE_BUCKET'] = Settings.encoding.masterfile_bucket = pipeline.pipeline.input_bucket
  ENV['SETTINGS__ENCODING__DERIVATIVE_BUCKET'] = Settings.encoding.derivative_bucket = pipeline.pipeline.output_bucket
end
