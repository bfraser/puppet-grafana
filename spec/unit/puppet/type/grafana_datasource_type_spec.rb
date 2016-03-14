# Copyright 2015 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'spec_helper'

describe Puppet::Type.type(:grafana_datasource) do
  context "when setting parameters" do

    it "should fail if grafana_url isn't HTTP-based" do
      expect {
        described_class.new :name => "foo", :grafana_url => "example.com", :content => "{}", :ensure => :present
      }.to raise_error(Puppet::Error, /not a valid URL/)
    end

    it "should fail if json_data isn't valid" do
      expect {
        described_class.new :name => "foo", :grafana_url => "http://example.com", :json_data => "invalid", :ensure => :present
      }.to raise_error(Puppet::Error, /json_data should be a Hash/)
    end

    it "should accept valid parameters" do
      resource = described_class.new :name => "foo", :grafana_url => "http://example.com", :url => 'http://influx.example.com'
      expect(resource[:name]).to eq('foo')
      expect(resource[:grafana_url]).to eq('http://example.com')
      expect(resource[:url]).to eq('http://influx.example.com')
    end
  end
end
