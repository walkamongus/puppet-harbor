require 'spec_helper'

describe Puppet::Type.type(:harbor_registry) do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      describe 'when validating attributes' do
        [ :name, :set_credential, :access_key, :access_secret, :type ].each do |param|
          it "should have a parameter '#{param}'" do
            expect(described_class.attrtype(param)).to eq(:param)
          end
        end
        [ :ensure, :description, :url, :insecure ].each do |prop|
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

        describe "set_credential" do
          [ 'false', 'true' ].each do |value|
            it "should support value '#{value}'" do
              expect { described_class.new({
                :name           => 'the_name',
                :set_credential => value,
              }) }.to_not raise_error
            end
          end

          it "should default to false" do
            expect(described_class.new({
              :name => 'the_name'
            })[:set_credential]).to eq :false
          end

          it "should not support other values" do
            expect { described_class.new({
              :name           => 'the_name',
              :set_credential => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "insecure" do
          [ 'false', 'true' ].each do |value|
            it "should support value '#{value}'" do
              expect { described_class.new({
                :name           => 'the_name',
                :insecure => value,
              }) }.to_not raise_error
            end
          end

          it "should default to false" do
            expect(described_class.new({
              :name => 'the_name'
            })[:insecure]).to eq :false
          end

          it "should not support other values" do
            expect { described_class.new({
              :name     => 'the_name',
              :insecure => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "type" do
          it "should default to 'harbor'" do
            expect(described_class.new({
              :name => 'the_name'
            })[:type]).to eq 'harbor'
          end
        end
      end
    end
  end
end