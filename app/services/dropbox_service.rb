module DropboxService
  class << self
    delegate :create_directory!, :dropbox, :dropbox_directory_name, :exists?, to: :service

    def service
      @service ||= ::DropboxService::FileSystem.new
    end
  end
end
