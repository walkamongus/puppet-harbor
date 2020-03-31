require 'spec_helper'

describe Puppet::Type.type(:harbor_replication_policy).provider(:swagger) do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      describe 'when validating class interface' do
        [ :instances, :prefetch ].each do |method|
          it "should have a method \"#{method}\"" do
            expect(described_class).to respond_to :method
          end
        end
      end
    end
  end
end