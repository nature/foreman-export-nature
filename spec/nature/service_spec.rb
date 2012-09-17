require 'spec_helper'

describe Nature::Service do
  include FakeFS::SpecHelpers

  before(:each) do
    # Bug in FakeFS, we dont need to worry about it here
    File.stub(:chmod)
  end

  describe ".new" do
    it "sets up the class propery" do
      path        = Pathname.new('/etc/sv/test-service')
      cwd         = Pathname.new('/apps/fake_app')
      command     = "cat foo"
      environment = Hash["FOO" => 'bar', "BAZ" => 'bat']

      result = Nature::Service.new(path, :command => command,
                                         :cwd => cwd,
                                         :environment => environment)

      result.cwd.should == '/apps/fake_app'
      result.environment.should == environment
      result.command.should == command

      result.path.should == '/etc/sv/test-service'
      result.active_path.should == '/service'

      result.run_script_path.should == '/etc/sv/test-service/run'
      result.log_script_path.should == '/etc/sv/test-service/log/run'
      result.log_dir.should == '/var/log/test-service'
    end
  end

  it "creates the necessary files and folders" do
    service = Nature::Service.new(Pathname.new('/etc/sv/test-service'), :command => 'ls -lah',
                                                                        :cwd => Pathname.new('/tmp/app'),
                                                                        :environment => {})
    service.create!

    File.exists?(service.run_script_path).should be_true
    File.exists?(service.log_script_path).should be_true
    File.directory?(service.log_dir).should be_true
  end

  it "can symlink the service to make it active" do
    FileUtils.should_receive(:ln_sf).with('/etc/sv/test-service', '/service')
    Nature::Service.new(Pathname.new('/etc/sv/test-service'), :command => 'ls -lah',
                                                              :cwd => Pathname.new('/tmp/app'),
                                                              :environment => {}).activate!
  end
end
