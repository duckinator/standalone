describe Standalone::Runtime::FileSystem do
  dfs = Standalone::Runtime::FileSystem

  # Runtime::FileSystem.activate! cannot be tested, as far as I know.

  it 'adds a file' do
    dfs.add_file('/x/y', 'z')
  end

  it 'can find an existing file' do
    dfs.has_file?('/x/y').should == true
  end

  it 'cannot find a nonexistent file' do
    dfs.has_file?('/x/a').should == false
  end

  it 'can read a file' do
    dfs.get_file('/x/y')[:contents].should == 'z'
  end

  it 'cannot read a nonexistent file' do
    dfs.get_file('/x/a')[:type].should == :nonexistent
  end

  testfile = File.expand_path('../data/file_system-test.txt', File.dirname(__FILE__))

  it 'can add a file from disk and read it back' do
    # I am well aware that this is bad, because it combines two functionalities
    # into one test. I'm not sure how to separate it, however.
    dfs.add_real_file(testfile)

    dfs.get_file(testfile)[:contents].should == open(testfile).read
  end

  it "has #{__FILE__.inspect}" do
    filename = __FILE__.sub(Standalone::Runtime::FileSystem::STANDALONE_REAL_GEM_PATH, Standalone::Runtime::FileSystem::STANDALONE_GEM_PATH)

    dfs.get_file(filename)[:contents].should == open(__FILE__).read
  end
end

