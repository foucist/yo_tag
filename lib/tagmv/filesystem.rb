require 'fileutils'

module Tagmv
  class Filesystem
    @root = File.expand_path('~/t')
    class << self
      attr_accessor :root
    end

    attr_reader :tags, :files, :reorder, :tag_order, :top_level_tags
    def initialize(opts={})
      @tags =  scrub_tags(opts[:tags])
      @files = opts[:files]
      @dry_run = opts[:dry_run]
      @reorder = opts[:reorder]
      @tag_order = opts[:tag_order]
      @top_level_tags = opts[:top_level_tags]
    end

    def scrub_tags(tags)
      # only keep legit file characters & remove trailing periods, remove duplicates after
      bad_chars =  /^[\-]|[^0-9A-Za-z\.\-\_]|[\.]+$/
      tags.map {|t| t.gsub(bad_chars, '') }.uniq
    end

    def scrub_files
      files.select do |file|
        path = File.expand_path(file)
        if File.exist?(path)
          path
        else
          puts "tmv: rename #{file} to #{target_dir}/#{File.basename(file)}: #{Errno::ENOENT.exception}"
          false
        end
      end
    end

    def tags_in_order
      return tags unless reorder

      (top_level_tags | tag_order) & tags
    end

    def tag_dirs
      tags_in_order.map {|x| x.gsub(/$/, '-') }
    end

    def target_dir
      File.join(Filesystem.root, *tag_dirs)
    end

    def prepare_dir
      @@prepare_dir ||= Hash.new do |h, key|
        h[key] = FileUtils.mkdir_p(key, options)
      end
      @@prepare_dir[target_dir]
    end

    def move_files
      # skip duplicate moves
      return if reorder && scrub_files.size == 1 && (scrub_files.first.sub(target_dir + '/','') !=~ /\//)

      FileUtils.mv(scrub_files, target_dir, options)
    rescue ArgumentError
    end

    def transfer
      prepare_dir && move_files
    end

    private
    def options
      if @dry_run
        {noop: true, verbose: true}
      else
        {}
      end
    end
  end
end
