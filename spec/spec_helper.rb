require 'coveralls'
Coveralls.wear!

require 'simplecov'

SimpleCov.configure do
  add_filter 'spec/'
end
SimpleCov.start unless ENV['TRAVIS']

require 'bundler/setup'

require 'rspec'

require 'standalone'


def capture(*streams)
  streams.map! { |stream| stream.to_s }
  begin
    result = StringIO.new
    streams.each { |stream| eval "$#{stream} = result" }
    yield
  ensure
    streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
  end
  result.string
end
