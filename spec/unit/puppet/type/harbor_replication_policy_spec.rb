require 'spec_helper'

describe Puppet::Type.type(:harbor_replication_policy) do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      describe 'when validating attributes' do
        [ :name, :remote_registry, :replication_mode,  ].each do |param|
          it "should have a parameter '#{param}'" do
            expect(described_class.attrtype(param)).to eq(:param)
          end
        end
        [ :deletion, :description, :dest_namespace, :enabled, :ensure, :filters, :override, :trigger ].each do |prop|
          it "should have a property '#{prop}'" do
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
            it "should support value '#{value}'" do
              expect { described_class.new({
                :name   => 'the_name',
                :ensure => value,
              })}.to_not raise_error
            end
          end

          it "should not support other values" do
            expect { described_class.new({
              :name   => 'the_name',
              :ensure => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "description" do
          it "should default to ''" do
            expect(described_class.new({
              :name => 'the_name'
            })[:description]).to eq ''
          end
        end

        describe "dest_namespace" do
          it "should default to ''" do
            expect(described_class.new({
              :name => 'the_name'
            })[:dest_namespace]).to eq ''
          end
        end

        describe "replication_mode" do
          [ 'push', 'pull' ].each do |value|
            it "should support value '#{value}'" do
              expect { described_class.new({
                :name             => 'the_name',
                :replication_mode => value,
              }) }.to_not raise_error
            end
          end

          it "should not support other values" do
            expect { described_class.new({
              :name             => 'the_name',
              :replication_mode => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "deletion" do
          [ false, true ].each do |value|
            it "should support value '#{value}'" do
              expect { described_class.new({
                :name     => 'the_name',
                :deletion => value,
              }) }.to_not raise_error
            end
          end

          it "should default to :false" do
            expect(described_class.new({
              :name => 'the_name'
            })[:deletion]).to eq :false
          end

          it "should not support other values" do
            expect { described_class.new({
              :name     => 'the_name',
              :deletion => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "override" do
          [ false, true ].each do |value|
            it "should support value '#{value}'" do
              expect { described_class.new({
                :name     => 'the_name',
                :override => value,
              }) }.to_not raise_error
            end
          end

          it "should default to :false" do
            expect(described_class.new({
              :name => 'the_name'
            })[:override]).to eq :false
          end

          it "should not support other values" do
            expect { described_class.new({
              :name     => 'the_name',
              :override => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "enabled" do
          [ false, true ].each do |value|
            it "should support value '#{value}'" do
              expect { described_class.new({
                :name    => 'the_name',
                :enabled => value,
              }) }.to_not raise_error
            end
          end

          it "should default to :true" do
            expect(described_class.new({
              :name => 'the_name'
            })[:enabled]).to eq :true
          end

          it "should not support other values" do
            expect { described_class.new({
              :name    => 'the_name',
              :enabled => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end
      end
    end
  end
end