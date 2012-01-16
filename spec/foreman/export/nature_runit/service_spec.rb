require 'spec_helper'

describe Foreman::Export::NatureRunit::Service do
  describe ".new" do
    subject { Foreman::Export::NatureRunit::Service }

    let(:target) { Pathname.new('~/').expand_path }
    let(:name)   { "test-service" }

    it "sets up the class propery" do
      result = subject.new(name, target)

      result.directory.should == target.join(name).expand_path
      result.active_target.should == target.join('..', '..', 'service', name).expand_path
    end
  end
end