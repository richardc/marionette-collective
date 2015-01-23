#!/usr/bin/env rspec

require 'spec_helper'

require 'mcollective/discovery/flatfile'

module MCollective
  class Discovery
    describe Flatfile do
      describe "#discover" do
        before do
          @client = mock
          @client.stubs(:options).returns({})
          @client.stubs(:options).returns({:discovery_options => ["/nonexisting"]})


          File.stubs(:readable?).with("/nonexisting").returns(true)
          File.stubs(:readlines).with("/nonexisting").returns(["one", "two"])
        end

        it "should use a file specified in discovery_options" do
          File.expects(:readable?).with("/nonexisting").returns(true)
          File.expects(:readlines).with("/nonexisting").returns(["one", "two"])
          Flatfile.discover(Util.empty_filter, 0, 0, @client).should == ["one", "two"]
        end

        it "should fail unless a file is specified" do
          @client.stubs(:options).returns({:discovery_options => []})
          expect { Flatfile.discover(Util.empty_filter, 0, 0, @client) }.to raise_error("The flatfile discovery method needs a path to a text file")
        end

        it "should fail for unreadable files" do
          File.expects(:readable?).with("/nonexisting").returns(false)

          expect { Flatfile.discover(Util.empty_filter, 0, 0, @client) }.to raise_error("Cannot read the file /nonexisting specified as discovery source")
        end

        it "should regex filters" do
          Flatfile.discover(Util.empty_filter.merge("identity" => [/one/]), 0, 0, @client).should == ["one"]
        end

        it "should filter against non regex nodes" do
          Flatfile.discover(Util.empty_filter.merge("identity" => ["one"]), 0, 0, @client).should == ["one"]
        end

        it "should fail for invalid identities" do
          ["four four", "foo$bar", "foo/bar"].each do |host|
            File.expects(:readlines).with("/nonexisting").returns([host])

            expect {
              Flatfile.discover(Util.empty_filter, 0, 0, @client)
            }.to raise_error(/Identities can only match/)
          end
        end

        it "should skip empty lines and comments" do
          host = ["one", "#two", "", "four"]
          File.expects(:readlines).with("/nonexisting").returns(host)
          Flatfile.discover(Util.empty_filter, 0, 0, @client).should == ["one", "four"]
        end
      end
    end
  end
end
