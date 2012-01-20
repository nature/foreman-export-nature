require 'spec_helper'

describe Foreman::Export::NatureRunit::Service do
  subject { Foreman::Export::NatureRunit::Service.new(name, command, execution_target, export_target, environment) }

  let(:execution_target) { Pathname.new('~/apps/fake_app') }
  let(:export_target)    { Pathname.new('~/etc/sv') }
  let(:name)             { "test-service" }
  let(:command)          { "cat foo" }
  let(:environment)      { Hash["FOO" => 'bar', "BAZ" => 'bat'] }

  before(:each) do
    subject.stub!(:create_if_missing)
    subject.stub!(:write_file)
    FileUtils.stub!(:chmod)
    FileUtils.stub!(:ln_sf)
    FileUtils.stub!(:rm)
    Dir.stub!(:[] => [])
  end

  describe ".new" do
    subject { Foreman::Export::NatureRunit::Service }

    it "sets up the class propery" do
      result = subject.new(name, command, execution_target, export_target, environment)

      result.execution_target.should == execution_target
      result.target.should == export_target.join(name)
      result.active_target.should == export_target.join('..', '..', 'service')
      result.environment.should == environment
      result.environment_target.should == result.target.join('env')
      result.command.should == command
    end
  end

  describe "#create!" do
    let(:fake_content) { "blabla" }

    it "trys to make the needed directory if its missing" do
      subject.should_receive(:create_if_missing).with(subject.target)
      subject.create!
    end

    it "generates a run script to save to disk" do
      subject.should_receive(:run_script).and_return(fake_content)
      subject.should_receive(:write_file).with(subject.target.join('run'), fake_content)

      subject.create!
    end

    it "chmod '0755'" do
      FileUtils.should_receive(:chmod).with(0755, subject.target.join('run').to_s)

      subject.create!
    end

  end

  describe "#run_script" do
    let(:fake_content) { "blabla" }
    let(:erb_template_double) { double('erb_template') }

    it "compiles the template with erb" do
      ERB.should_receive(:new).with(Foreman::Export::NatureRunit::Service.run_template.read).and_return(erb_template_double)
      erb_template_double.should_receive(:result).and_return(fake_content)

      subject.run_script.should == fake_content
    end
  end

  describe "activate!" do
    it "symlinks the service into the 'running' dir" do
      FileUtils.should_receive(:ln_sf).with(subject.target, subject.active_target)

      subject.activate!
    end
  end
end