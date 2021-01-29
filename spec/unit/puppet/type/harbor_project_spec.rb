require 'spec_helper'

describe Puppet::Type.type(:harbor_project) do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      describe 'when validating attributes' do
        [ :name ].each do |param|
          it "should have a parameter '#{param}'" do
            expect(described_class.attrtype(param)).to eq(:param)
          end
        end
        [ :ensure, :public, :members, :member_groups, :auto_scan ].each do |prop|
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
          [ :false, :true ].each do |value|
            it "should support value: #{value}" do
              expect { described_class.new({
                :name   => 'the_project',
                :public => value,
              }) }.to_not raise_error
            end
          end

          it "should default to :false" do
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

        describe "auto_scan" do
          [ :false, :true ].each do |value|
            it "should support value: #{value}" do
              expect { described_class.new({
                :name      => 'the_project',
                :auto_scan => value,
              }) }.to_not raise_error
            end
          end

          it "should default to :false" do
            expect(described_class.new({
              :name => 'the_project'
            })[:auto_scan]).to eq :false
          end

          it "should not support other values" do
            expect { described_class.new({
              :name      => 'the_project',
              :auto_scan => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end
        end

        describe "members" do
          [ [], ['a_name'], ['a_name', 'another_name']].each do |value|
            it "should support array of string values: #{value}" do
              expect { described_class.new({
                :name    => 'the_project',
                :members => value,
              }) }.to_not raise_error
            end
          end
        end

        describe "member_groups" do
          [ [], ['a_group'], ['a_group', 'another_group']].each do |value|
            it "should support array of string values: #{value}" do
              expect { described_class.new({
                :name          => 'the_project',
                :member_groups => value,
              }) }.to_not raise_error
            end
          end
        end
      
        describe "guests" do
          [ [], ['a_name'], ['a_name', 'another_name']].each do |value|
            it "should support array of string values: #{value}" do
              expect { described_class.new({
                :name  => 'the_project',
                :guest => value,
              }) }.to_not raise_error
            end
          end
        end

        describe "guest_groups" do
          [ [], ['a_group'], ['a_group', 'another_group']].each do |value|
            it "should support array of string values: #{value}" do
              expect { described_class.new({
                :name         => 'the_project',
                :guest_groups => value,
              }) }.to_not raise_error
            end
          end
        end
      end
    end
  end
end