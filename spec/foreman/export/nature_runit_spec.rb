require 'spec_helper'

describe Foreman::Export::NatureRunit do
  let(:engine)      { Foreman::Engine.new("/Procfile") }
  let(:export_path) { Pathname.new('~/etc/sv') }

  before(:each) do
    File.stub!(:read => procfile)
  end

  describe "#export" do
    subject { Foreman::Export::NatureRunit.new(export_path.to_s, engine, :app => 'test-application') }

    let(:service_double) { double('Service') }

    context "a single process" do
      let(:service)  { "foo" }
      let(:command)  { "bundle exec #{ service }" }
      let(:procfile) { "#{ service }: #{ command }" }
      let(:port)     { 5000 }
      let(:env)      { Hash['SERVER_PORT' => 6000]}

      it "exports the process with its options" do
        engine.should_receive(:port_for).with(kind_of(Foreman::ProcfileEntry), 1, nil).and_return(port)
        engine.should_receive(:environment).and_return(env)

        Foreman::Export::NatureRunit::Service.should_receive(:new).with("test-application-#{ service }-1", command, export_path, {'PORT' => port}.merge(env)).and_return(service_double)
        service_double.should_receive(:create!).once
        service_double.should_receive(:activate!).once

        subject.export
      end
    end

    context "with inline concurrency options" do
      subject { Foreman::Export::NatureRunit.new(export_path.to_s, engine, :concurrency => 'foo=2', :app => 'test-application') }

      let(:procfile) do
"""
foo: bundle exec foo
bar: bundle exec bar
"""
end

      it "exports each instance" do
        Foreman::Export::NatureRunit::Service.should_receive(:new).with("test-application-foo-1", "bundle exec foo", export_path, kind_of(Hash)).and_return(service_double)
        Foreman::Export::NatureRunit::Service.should_receive(:new).with("test-application-foo-2", "bundle exec foo", export_path, kind_of(Hash)).and_return(service_double)
        Foreman::Export::NatureRunit::Service.should_receive(:new).with("test-application-bar-1", "bundle exec bar", export_path, kind_of(Hash)).and_return(service_double)

        service_double.should_receive(:create!).exactly(3).times
        service_double.should_receive(:activate!).exactly(3).times

        subject.export
      end
    end

  end
end