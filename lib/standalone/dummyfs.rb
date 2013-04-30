module Standalone
  module DummyFS
    # Worst excuse of an FS ever.

    FAKE_GEM_DIR = File.join('home', 'sicuro', '.gem', 'ruby', RUBY_VERSION, 'gems')
    STANDALONE_GEM_PATH = File.join(FAKE_GEM_DIR, 'standalone', 'lib', 'standalone')

    class << self
      def activate!
        $:.clear
        $: << STANDALONE_GEM_PATH
      end

      def has_file?(file)
        ret = find_file(file)
        ret && !ret.empty?
      end

      def find_file(file)
        return [] unless file # find_file(nil) => everything.

        @@files.keys.grep(%r[#{file}(\..*)?$])
      end

      def add_file(name, contents)
        @@files ||= {}
        @@files[name] = contents
      end

      def add_real_file(file, name = nil)
        name ||= file
        DummyFS.add_file(name, open(file).read)
      end

      def get_file(file)
        return @@files[file] if @@files.keys.include?(file)
        raise ::Errno::ENOENT, "No such file or directory - #{file}"
      end
    end

    Dir[File.join(File.dirname(__FILE__), '..', '**', '*.rb')].each do |filename|
      fake_filename = filename.gsub(File.dirname(__FILE__), '').gsub(%r[^/..], STANDALONE_GEM_PATH)
      DummyFS.add_real_file(filename, fake_filename)
    end
  end
end
