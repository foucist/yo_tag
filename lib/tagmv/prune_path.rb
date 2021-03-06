module Tagmv
  class PrunePath
    attr_reader :path
    def initialize(path)
      @path = path
    end

    def tag_dir?
      path =~ /..-$/ && path !~ Tagmv::Tree.false_tag_regex
    end

    def empty_dir?
      FileTest.directory?(path) && Dir.entries(path) == ['.', '..']
    end

    def rmdir
      Dir.rmdir(path) if tag_dir? && empty_dir?
    end

    def self.prune_tag_dirs
      Find.find(Tagmv::Filesystem.root).reverse_each do |path|
        Tagmv::PrunePath.new(path).rmdir
      end
    end

  end
end
