module Standalone
  module DummyFS
    # Worst excuse of an FS ever.

    FAKE_GEM_DIR = File.join('home', 'sicuro', '.gem', 'ruby', RUBY_VERSION, 'gems')
    STANDALONE_GEM_PATH = File.join(FAKE_GEM_DIR, 'standalone', 'lib', 'standalone')

    class << self
      @@configured = false

      def setup
        return if @@configured
        @@configured ||= true

        Dir[File.join(File.dirname(__FILE__), '..', '**', '*.rb')].each do |filename|
          fake_filename = filename.gsub(File.dirname(__FILE__), '').gsub(%r[^/..], STANDALONE_GEM_PATH)
          DummyFS.add_real_file(filename, fake_filename)
        end
      end

      def activate!
        $:.clear
        $: << STANDALONE_GEM_PATH
      end

      def has_file?(filename)
        ret = find_file(filename)
        ret && !ret.empty?
      end

      def find_file(filename)
        return [] unless filename # find_file(nil) => everything.

        @@files.keys.grep(%r[#{filename}(\..*)?$])
      end

      def add_file(filename, contents)
        @@files ||= {}
        @@files[filename] = contents
      end

      def add_real_file(filename, name = nil)
        name ||= filename
        DummyFS.add_file(name, open(file).read)
      end

      def get_file(filename)
        return @@files[filename] if @@files.keys.include?(filename)
        raise ::Errno::ENOENT, "No such file or directory - #{filename}"
      end
    end

    setup
  end
end
