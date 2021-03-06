require 'test_helper'

class FilesystemTest < Minitest::Test
  def before 
    @dir = Dir.mktmpdir
    Tagmv::Filesystem.root = @dir
  end

  def after
    FileUtils.remove_entry @dir
  end


  def test_it_uses_root_for_target_dir
    dir = '/tmp/foobar'
    Tagmv::Filesystem.root = dir
    tags = ['a','b']

    tfs = Tagmv::Filesystem.new(tags: tags, files: [])
    def tfs.tag_order; tags; end

    assert tfs.target_dir == "/tmp/foobar/a-/b-"
  end

  def test_it_makes_tag_dirs
    before

    tags = ['a', 'b', 'c']
    tfs = Tagmv::Filesystem.new(tags: tags, files: [])
    def tfs.tag_order; tags; end

    assert File.exist?(tfs.target_dir) == false
    tfs.prepare_dir
    assert File.exist?(tfs.target_dir) == true

    after
  end

  def test_it_moves_file_to_tag_dirs
    before
    tags = ['a', 'b', 'c']

    file = File.join(@dir, 'timestamp')
    assert FileUtils.touch(file)

    tfs = Tagmv::Filesystem.new(tags: tags, files: [file])
    def tfs.tag_order; tags; end

    tfs.transfer
    assert File.exist?(File.join(tfs.target_dir, 'timestamp'))

    after
  end

  def test_it_moves_directory_to_tag_dirs
    #FileUtils.mv Dir.glob('test*.rb'), 'test'
  end

  def test_it_moves_multiple_things_to_tag_dirs
  end
end
