require 'aws-sdk'

ActiveEncode::Base.engine_adapter = Settings.encoding.engine_adapter.to_sym
case Settings.encoding.engine_adapter.to_sym
when :matterhorn
  Rubyhorn.init
when :elastic_transcoder
  MasterFile.default_encoder_class = ElasticTranscoderJob
  pipeline = Aws::ElasticTranscoder::Client.new.read_pipeline(id: Settings.encoding.pipeline)
  Settings.encoding.masterfile_bucket = pipeline.pipeline.input_bucket
  Settings.encoding.derivative_bucket = pipeline.pipeline.output_bucket
end
