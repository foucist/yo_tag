module TagMv
  class Entry
    attr_accessor :tags, :file
    def initialize(opts={})
      @tags = opts[:tags]
      @file = opts[:file]
    end
  end
end
