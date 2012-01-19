require 'spec_helper'

describe Foreman::Export::NatureRunit::Service do
  subject { Foreman::Export::NatureRunit::Service.new(name, command, execution_target, export_target, environment) }

  let(:execution_target) { Pathname.new('~/apps/fake_app').expand_path }
  let(:export_target)    { Pathname.new('~/etc/sv').expand_path }
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
      result.target.should == export_target.join(name).expand_path
      result.active_target.should == export_target.join('..', '..', 'service', name).expand_path
      result.logging_target.should == export_target.join('..', '..', 'var', 'log', name).expand_path
      result.environment.should == environment
      result.environment_target.should == result.target.join('env').expand_path
      result.command.should == command
    end
  end

  describe "create!" do
    it "calls [#export_run_script!]" do
      subject.should_receive(:export_run_script!)
      subject.create!
    end

    it "calls [#export_log_script!]" do
      subject.should_receive(:export_log_script!)
      subject.create!
    end
  end

  describe "#export_log_script!" do
    let(:fake_content) { "blabla" }

    it "does something" do
      subject.should_receive(:create_if_missing).with(subject.target.join('log'))
      subject.should_receive(:create_if_missing).with(subject.logging_target)
      
      subject.export_log_script!
    end

    it "generates a log script to save to disk" do
      subject.should_receive(:log_script).and_return(fake_content)
      subject.should_receive(:write_file).with(subject.target.join('log', 'run'), fake_content)

      subject.export_log_script!
    end

    it "chmod '0755'" do
      FileUtils.should_receive(:chmod).with(0755, subject.target.join('log', 'run').to_s)

      subject.export_log_script!
    end
  end

  describe "#log_script" do
    let(:fake_content) { "blabla" }
    let(:erb_template_double) { double('erb_template') }

    it "compiles the template with erb" do
      ERB.should_receive(:new).with(Foreman::Export::NatureRunit::Service.log_template.read).and_return(erb_template_double)
      erb_template_double.should_receive(:result).and_return(fake_content)

      subject.log_script.should == fake_content
    end
  end

  describe "#export_run_script!" do
    let(:fake_content) { "blabla" }

    it "trys to make the needed directory if its missing" do
      subject.should_receive(:create_if_missing).with(subject.target)
      subject.export_run_script!
    end

    it "generates a run script to save to disk" do
      subject.should_receive(:run_script).and_return(fake_content)
      subject.should_receive(:write_file).with(subject.target.join('run'), fake_content)

      subject.export_run_script!
    end

    it "chmod '0755'" do
      FileUtils.should_receive(:chmod).with(0755, subject.target.join('run').to_s)

      subject.export_run_script!
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