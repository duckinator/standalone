require 'standalone/file'
require 'standalone/stringio'
require 'standalone/runtime/file_system'

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

      if read && !File.exist?(filename)
        raise Errno::ENOENT, filename
      end

      if read && !File.file?(filename)
        raise ArgumentError, "invalid access mode #{mode}"
      end

      existing = ''
      existing = Runtime::FileSystem.get_file(filename)[:contents] if File.file?(filename)

      f ||= super(existing)
    end

    def close
      Runtime::FileSystem.add_file(@filename, string)[:contents]
    end

    class << self
      def exist?(filename)
        Runtime::FileSystem.has_file?(filename)
      end
      alias :'exists?' :'exist?'

      def open(filename, mode = 'r', opt = nil, &block)
        f = self.new(filename, mode, opt, &block)
        if block_given?
          yield f
          f.close
        else
          f
        end
      end

      # FIXME: File.file? should actually check if it's a file
      def file?(filename)
        exist?(filename) && Runtime::FileSystem.get_file(filename)[:type] == :file
      end

      # FIXME: File.directory? should actually check if it's a directory
      def directory?(filename)
        exist?(filename) && Runtime::FileSystem.get_file(filename)[:type] == :dir
      end

      def dirname(path)
        path.split('/')[0..-2].join('/')
      end

      def join(*args)
        args.join('/')
      end

      # FIXME: File.expand_path is bullshit.
      def expand_path(file_name, dir_string = nil)
        # TODO: do something with dir_string

        parent_dir_cancel = /(^|\/).*\/..(\/|$)/
        file_name.sub!(parent_dir_cancel, '') while file_name =~ parent_dir_cancel

        parent_dir_userless = /^..\//
        file_name.sub!(parent_dir_userless, '') while file_name =~ parent_dir_userless

        file_name
      end

    end

  end
end
