module DropboxService
  class FileSystem
    def create_directory!(name)
      original_name = name.dup.freeze
      iter = 2
      while exists?(name)
        name = "#{original_name}_#{iter}"
        iter += 1
      end

      absolute_path = absolute_path(name)

      unless File.directory?(absolute_path)
        begin
          Dir.mkdir(absolute_path)
        rescue Exception => e
          Rails.logger.error "Could not create directory (#{absolute_path}): #{e.inspect}"
        end
      end
      name
    end

    def dropbox(name)
      Avalon::Dropbox.new(absolute_path, self)
    end

    def dropbox_directory_name(name)
      absolute_path(name)
    end

    def exists?(name)
      File.exists?(absolute_path(name))
    end

    protected
      def absolute_path(name)
        File.join(Avalon::Configuration.lookup('dropbox.path'), name)
      end
  end
end
