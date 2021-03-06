module Standalone
  module Runtime
    module FileSystem
      # Worst excuse of a filesystem ever.

      FAKE_GEM_DIR = File.join('', 'home', 'standalone', '.gem', 'ruby', RUBY_VERSION, 'gems')
      STANDALONE_GEM_PATH = File.join(FAKE_GEM_DIR, 'standalone')

      STANDALONE_REAL_GEM_PATH = File.expand_path('../../../', File.dirname(__FILE__))

      class << self
        @@configured = false
        @@fs = { type: :dir, files: {} }
        @@libraries = []

        def fs
          @@fs
        end

        def setup!
          return if @@configured
          @@configured ||= true

          add_real_directory(STANDALONE_REAL_GEM_PATH, '*.rb', true) do |filename|
            filename.sub(STANDALONE_REAL_GEM_PATH, STANDALONE_GEM_PATH)
          end
        end

        def enable!
          $:.clear

          @@libraries.each do |library|
            $: << library
          end
        end

        def add_library(library)
          @@libraries << library
          $: << library
        end

        def has_file?(filename)
          ret = find_file(filename)
          ret && !ret.empty?
        end

        def find_file(filename)
          return [] unless filename # find_file(nil) => everything.

          parts = filename.split('/')
          filename = parts[-1]
          tmp = @@fs

          i = 0
          while i < (parts.length - 1)
            dir = parts[i]

            return {} unless tmp[:files].include?(dir)

            tmp = tmp[:files][dir]
            i += 1
          end

          # Inefficiencies, ahoy!

          ret = {}
          regexp = %r[#{filename}(\..*)?$]
          tmp[:files].each do |key, val|
            if key.match(regexp)
              ret[key] = val
            end
          end
          ret
        end

        def add_file(filename, contents)
          parts = filename.split('/')
          dirname  = parts[0..-2].join('/')
          filename = parts[-1]

          add_directory(dirname)[:files][filename] = { type: :file, contents: contents}
        end

        def add_real_file(filename, name = nil)
          name ||= filename
          add_file(name, open(filename).read)
        end

        def add_directory(filename)
          parts = filename.split('/')

          tmp = @@fs

          i = 0
          while i < parts.length
            dir = parts[i]

            unless tmp[:files].include?(dir)
              tmp[:files][dir] = { type: :dir, files: {} }
            end
            tmp = tmp[:files][dir]

            i += 1
          end

          tmp
        end

        def add_real_directory(dirname, file_glob='*', library=false, &block)
          Dir[::File.join(dirname, '**', file_glob)].each do |filename|
            filename = File.expand_path(filename)

            if ::File.directory?(filename)
              add_real_directory(filename, file_glob, false, &block)
            else
              fake_filename = filename
              fake_filename = yield(filename) if block_given?

              add_real_file(filename, fake_filename)
            end
          end

          if library
            lib_dir = File.expand_path(File.join(dirname, 'lib'))

            if block_given?
              add_library yield(lib_dir)
            else
              add_library lib_dir
            end
          end
        end

        def get_file(filename)
          parts = filename.split('/')
          filename = parts[-1]
          tmp = @@fs
          error = false

          i = 0
          while i < (parts.length - 1)
            dir = parts[i]

            unless tmp[:files].include?(dir)
              error = true
              break
            end
            tmp = tmp[:files][dir]

            i += 1
          end

          return tmp[:files][filename] if tmp[:files].keys.include?(filename) && !error
          { :type => :nonexistent }
        end
      end

      setup!
    end
  end
end
