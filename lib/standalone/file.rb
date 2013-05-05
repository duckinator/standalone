require 'standalone/file'
require 'standalone/stringio'
require 'standalone/dummyfs'

module Standalone
  class File < StringIO
    SEPARATOR = "/"
    ALT_SEPARATOR = nil
    Separator = SEPARATOR
    PATH_SEPARATOR = ":"
#    Constants = File::Constants
#    Stat = File::Stat

#    WaitReadable = IO::WaitReadable
#    WaitWritable = IO::WaitWritable

    SEEK_SET = 0
    SEEK_CUR = 1
    SEEK_END = 2

    LOCK_SH = 1
    LOCK_EX = 2
    LOCK_UN = 8
    LOCK_NB = 4

    NULL = "/dev/null"

    RDONLY = 0
    WRONLY = 1
    RDWR = 2
    APPEND = 1024
    CREAT = 64
    EXCL = 128
    NONBLOCK = 2048
    TRUNC = 512
    NOCTTY = 256
    BINARY = 0
    SYNC = 1052672
    DSYNC = 4096
    RSYNC = 1052672
    NOFOLLOW = 131072
    NOATIME = 262144
    DIRECT = 16384
    FNM_NOESCAPE = 1
    FNM_PATHNAME = 2
    FNM_DOTMATCH = 4
    FNM_CASEFOLD = 8
    FNM_SYSCASE = 0

    def initialize(filename, mode = 'r', opt = nil)
      @filename = filename
      @mode = mode
      @opt  = opt
      f = nil
      start = :end
      read  = true
      write = false
      truncate = false

      case mode
      when "r"
        # Read-only, starts at beginning of file  (default mode).
        start = :beginning
        read  = true
        write = false
        truncate = false
      when "r+"
        # Read-write, starts at beginning of file.
        start = :beginning
        read  = true
        write = true
        truncate = false
      when "w"
        # Write-only, truncates existing file
        # to zero length or creates a new file for writing.
        start = :beginning
        read  = false
        write = true
        truncate = true
      when "w+"
        # Read-write, truncates existing file to zero length
        # or creates a new file for reading and writing.
        start = :beginning
        read  = true
        write = true
        truncate = true
      when "a"
        # Write-only, starts at end of file if file exists,
        # otherwise creates a new file for writing.
        start = :end
        read  = false
        write = true
        truncate = false
      when "a+"
        # Read-write, starts at end of file if file exists,
        # otherwise creates a new file for reading and writing.
        start = :end
        read  = true
        write = true
        truncate = false
      end

      if read && !Standalone::File.file?(filename)
        raise ArgumentError, "invalid access mode #{mode}"
      end

      existing = ''
      existing = DummyFS.get_file(filename) if Standalone::File.file?(filename)
      f ||= super(existing)
      if block_given?
        yield f
        close
      end
      f
    end

    def close
      DummyFS.add_file(@filename, string)
    end

    class << self
      def exist?(filename)
        DummyFS.has_file?(filename)
      end
      alias :'exists?' :'exist?'

      def open(filename, mode = 'r', opt = nil, &block)
        #raise ::NotImplementedError, "Sandboxed File.open() only supports reading files."
        self.new(filename, mode, opt, &block)
      end

      # FIXME: File.file? should actually check if it's a file
      def file?(filename)
        exist?(filename)
      end

      # FIXME: File.directory? should actually check if it's a directory
      def directory?(filename)
        exist?(filename)
      end

      def dirname(path)
        path.split('/')[0..-2].join('/')
      end

      def join(*args)
        args.join('/')
      end
    end

  end
end
