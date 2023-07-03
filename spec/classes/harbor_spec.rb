# frozen_string_literal: true

require 'spec_helper'

describe 'harbor' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('docker') }
      it { is_expected.to contain_class('harbor::install') }
      it { is_expected.to contain_class('harbor::config') }
      it { is_expected.to contain_class('harbor::prepare') }
      it { is_expected.to contain_class('harbor::service') }

      describe 'harbor::install' do
        context 'with init default params' do
          it do
            is_expected.to contain_archive('/tmp/harbor-offline-installer-v2.8.2.tgz').with(
              'source' => 'https://github.com/goharbor/harbor/releases/download/v2.8.2/harbor-offline-installer-v2.8.2.tgz'
            )
          end
          it { is_expected.to contain_file('/opt/harbor-v2.8.2') }
          it { is_expected.to contain_file('/opt/harbor') }
          it { is_expected.to contain_docker__image('goharbor/harbor-log') }
        end
      end

      describe 'harbor::config' do
        context 'with init default params' do
          it do
            is_expected.to contain_file('/opt/harbor/harbor.yml')
            is_expected.to contain_exec('migrate_cfg')
          end
        end
      end

      describe 'harbor::prepare' do
        context 'with init default params' do
          it do
            is_expected.to contain_exec('prepare_harbor')
          end
        end
      end

      describe 'harbor::service' do
        context 'with init default params' do
          it do
            is_expected.to contain_file('harbor_service_unit').with_content(%r{ExecStart=/usr/local/bin/docker-compose -f /opt/harbor/docker-compose.yml up --remove-orphans})
            is_expected.to contain_service('harbor')
          end
        end
      end
    end

    context "with backup_enabled equals true and with missing fact 'harbor_systeminfo'" do
      let(:facts) do
        os_facts.merge({
          :harbor_systeminfo => nil,
        })
      end

      let(:params) { {'backup_enabled' => true} }

      it { is_expected.to raise_error(Puppet::PreformattedError, /Backup failed because fact\['harbor_systeminfo'\] is not available./) }
    end

    context "with backup_enabled equals true and with missing fact 'harbor_systeminfo''harbor_version'" do
      let(:facts) do
        os_facts.merge({
          :harbor_systeminfo => {:some_key => 'value'},
        })
      end
      let(:params) { {'backup_enabled' => true} }
      it { is_expected.to raise_error(Puppet::PreformattedError, /Backup failed because fact\['harbor_systeminfo'\]\['harbor_version'\] is not available./) }
    end

    context "with backup_enabled equals true and fact 'harbor_systeminfo''harbor_version'" do
      let(:facts) do
        os_facts.merge({
          :harbor_systeminfo => {:harbor_version => 'v1.10.6-490042d8'},
        })
      end
      let(:params) { {'backup_enabled' => true} }

      it { is_expected.to contain_class('harbor::backup') }

      describe 'harbor::backup' do
        context 'with init default params' do
          it do
            is_expected.to contain_exec('stop_harbor')
            is_expected.to contain_exec('back_up_harbor_database').with(
                  'require' => 'Exec[stop_harbor]',
                )
          end
        end
      end
    end
  end
end
