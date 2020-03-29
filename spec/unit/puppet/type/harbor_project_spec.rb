require 'spec_helper'

describe Puppet::Type.type(:harbor_project) do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      describe 'when validating attributes' do
        [ :name ].each do |param|
          it "should have a parameter \"#{param}\"" do
            expect(described_class.attrtype(param)).to eq(:param)
          end
        end
        [ :public, :members, :member_groups ].each do |prop|
          it "should have a property \"#{prop}\"" do
            expect(described_class.attrtype(prop)).to eq(:property)
          end
        end
      end

      describe "namevar validation" do
        it "should have :name as its namevar" do
          expect(described_class.key_attributes).to eq([:name])
        end
      end

      describe 'when validating attribute values' do
        describe 'ensure' do
          [ :present, :absent ].each do |value|
            it "should support \"#{value}\" as a value to \"ensure\"" do
              expect { described_class.new({
                :name   => 'the_project',
                :ensure => value,
              })}.to_not raise_error
            end
          end

          it "should not support other values" do
            expect { described_class.new({
              :name   => 'the_project',
              :ensure => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "public" do
          [ 'false', 'true' ].each do |value|
            it "should support '#{value}' as a value for \"public\"" do
              expect { described_class.new({
                :name   => 'the_project',
                :public => value,
              }) }.to_not raise_error
            end
          end

          it "should default to false" do
            expect(described_class.new({
              :name => 'the_project'
            })[:public]).to eq :false
          end

          it "should not support other values" do
            expect { described_class.new({
              :name   => 'the_project',
              :public => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end
      end
    end
  end
end