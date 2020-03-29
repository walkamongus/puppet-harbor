require 'spec_helper'

describe Puppet::Type.type(:harbor_project).provider(:swagger) do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before :each do
        Facter.clear
        facts.each do |k, v|
          Facter.stubs(:fact).with(k).returns Facter.add(k) { setcode { v } }
        end
      end

      describe 'instances' do
        it 'should have an method \"instances\"' do
          expect(described_class).to respond_to :instances
        end
      end

      describe 'prefetch' do
        it 'should have a method \"prefetch\"' do
          expect(described_class).to respond_to :prefetch
        end
      end
    end
  end
end