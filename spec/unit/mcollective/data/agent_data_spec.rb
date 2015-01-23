#!/usr/bin/env rspec

require 'spec_helper'

require 'mcollective/data/agent_data'

module MCollective
  module Data
    describe Agent_data do
      describe "#query_data" do
        before do
          @ddl = mock
          @ddl.stubs(:dataquery_interface).returns({:output => {}})
          @ddl.stubs(:meta).returns({:timeout => 1})
          DDL.stubs(:new).returns(@ddl)
          @plugin = Agent_data.new
        end

        it "should fail for unknown agents" do
          expect { @plugin.query_data("rspec") }.to raise_error("No agent called rspec found")
        end

        it "should retrieve the correct agent and data" do
          agent = mock
          agent.stubs(:meta).returns({:license => "license",
                                        :timeout => "timeout",
                                        :description => "description",
                                        :url => "url",
                                        :version => "version",
                                        :author => "author"})

          PluginManager.stubs(:[]).with("rspec_agent").returns(agent)
          PluginManager.expects(:include?).with("rspec_agent").returns(true)

          @plugin.query_data("rspec")

          [:license, :timeout, :description, :url, :version, :author].each do |item|
            @plugin.result[item].should == item.to_s
          end
        end
      end
    end
  end
end
