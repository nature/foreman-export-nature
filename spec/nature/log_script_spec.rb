require 'spec_helper'

describe Nature::LogScript do
  include FakeFS::SpecHelpers

  it "has appropriate content" do
    script = Nature::LogScript.new(:path => "/foo/bar/web", :log_to => '/var/log/web')
    script.content.should == """#!/bin/sh

exec svlogd -tt /var/log/web
"""

  end

  it "exports to the appropriate place" do
    File.should_receive(:chmod).with(0755, File.expand_path('/foo/bar/web'))
    Nature::LogScript.new(:path => "/foo/bar/web", :log_to => '/var/log/web').export

    File.file?('/foo/bar/web').should be_true
  end
end
