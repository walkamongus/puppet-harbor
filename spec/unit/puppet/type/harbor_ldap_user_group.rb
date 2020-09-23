require 'spec_helper'
require 'rspec-puppet'

describe Puppet::Type.type(:harbor_ldap_user_group) do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      describe 'when validating attributes' do
        [ :ldap_group_dn ].each do |param|
          it "should have a parameter '#{param}'" do
            expect(described_class.attrtype(param)).to eq(:param)
          end
        end
        [ :ensure, :group_name ].each do |prop|
          it "should have a property '#{prop}'" do
            expect(described_class.attrtype(prop)).to eq(:property)
          end
        end
      end

      describe "namevar validation" do
        it "should have :ldap_group_dn as its namevar" do
          expect(described_class.key_attributes).to eq([:ldap_group_dn])
        end
      end

      describe 'when validating attribute values' do
        describe 'ensure' do
          [ :present, :absent ].each do |value|
            it "should support value '#{value}'" do
              expect { described_class.new({
                :ensure        => value,
                :ldap_group_dn => 'cn=ProjectA,ou=Users,dc=example,dc=local',
                :group_name    => 'the_name',
              })}.to_not raise_error
            end
          end

          it "should not support other values" do
            expect { described_class.new({
              :ldap_group_dn => 'dn',
              :group_name    => 'the_name',
              :ensure        => 'other_value',
            })}.to raise_error(Puppet::Error, /Invalid value/)
          end

          it "should default to :present" do
            expect(described_class.new({
              :ldap_group_dn => 'dn',
              :group_name    => 'the_name',
            })[:ensure]).to eq :present
          end
        end
      end
    end
  end
end