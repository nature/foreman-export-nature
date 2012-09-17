require 'spec_helper'

describe Foreman::Export::NatureRunit do
  include FakeFS::SpecHelpers

  before(:each) do
    # Bug in FakeFS, we dont need to worry about it here
    File.stub(:chmod)
  end

  let(:engine)   { Foreman::Engine.new(:formation => "web=2,background=1").load_procfile(procfile) }
  let(:options)  { Hash.new }
  let(:procfile) { write_procfile("/tmp/app/Procfile", <<-EOP)
web: bundle exec thin --port $PORT
background: bundle exec sidekiq
EOP
}

  it "intergrates with foreman to export all the peices to the filesystem" do
    Foreman::Export::NatureRunit.new('/etc/sv', engine, options).export

    # Simple sanity check, don't duplicate the work of the unit tests
    File.file?('/etc/sv/app-web-1/run').should be_true
    File.file?('/etc/sv/app-web-2/run').should be_true
    File.file?('/etc/sv/app-background-1/run').should be_true
  end
end
