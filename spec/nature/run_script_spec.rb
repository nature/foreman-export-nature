require 'spec_helper'
require 'fakefs/spec_helpers'

describe Nature::RunScript do
  include FakeFS::SpecHelpers

  it "has appropriate content" do
    script = Nature::RunScript.new(:name => "web",
                                   :command => "bundle exec unicorn",
                                   :env => { 'PORT' => '5000', 'PATH' => '"/etc/foo"' },
                                   :cwd => '/foo/bar/app')

    script.content.should == """#!/bin/sh
exec 2>&1

[[ -e ~/.bash_profile ]] && source ~/.bash_profile

export PORT=\"5000\"
export PATH=\"\\\"/etc/foo\\\"\"

[[ $RVM_VERSION_STRING ]] && rvm use \"$RVM_VERSION_STRING\"

cd /foo/bar/app
exec bundle exec unicorn
"""

  end


  it "exports to the appropriate place" do
    File.should_receive(:chmod).with(0755, File.expand_path('~/etc/sv/web/run'))
    Nature::RunScript.new(:name => "web",
                          :command => "bundle exec unicorn",
                          :env => { 'PORT' => '5000' },
                          :cwd => '/foo/bar/app').export
    File.file?(File.expand_path('~/etc/sv/web/run')).should be_true

    # Doesn't work in fakefs
    # File.new(File.expand_path('~/etc/sv/web/run')).stat.mode.should == '755'
  end
end
