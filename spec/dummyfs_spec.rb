describe Standalone::DummyFS do
  dfs = Standalone::DummyFS

  # DummyFS.activate! cannot be tested, as far as I know.

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

  testfile = File.join(File.dirname(__FILE__), 'data', 'dummyfs-test.txt')

  it 'can add a file from disk and read it back' do
    # I am well aware that this is bad, because it combines two functionalities
    # into one test. I'm not sure how to separate it, however.
    dfs.add_real_file(testfile)
    dfs.get_file(testfile)[:contents].should == open(testfile).read
  end
end

describe Standalone::File do
  file = Standalone::File

  file.open('a', 'w') {|f| f.puts "test" }.should == "test\n"
  file.open('a', 'r') {|f| f.read }.should == "test\n"

  file.exist?('a').should == true
  file.file?('a').should == true
  file.directory?('a').should == false

  file.dirname('a/b').should == "a"
  file.join('a', 'b').should == "a/b"
end
