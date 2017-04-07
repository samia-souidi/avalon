# Taken from https://github.com/projecthydra-labs/hyku/blob/master/lib/tasks/zookeeper.rake
namespace :zookeeper do
  desc 'Push solr configs into zookeeper'
  task upload: [:environment] do
    SolrConfigUploader.default.upload(Settings.solr.configset)
  end

  desc 'Create a collection'
  task create: [:environment] do
    #TODO implement SolrCloud create collection
  end

  desc 'Delete solr configs from zookeeper'
  task delete_all: [:environment] do
    SolrConfigUploader.default.delete_all
  end
end
