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

