if Rails.env.aws?
  ActiveEncode::Base.engine_adapter = :elastic_transcoder
  MasterFile.default_encoder_class = ElasticTranscoderJob
else
  ActiveEncode::Base.engine_adapter = :matterhorn
  Rubyhorn.init
end
