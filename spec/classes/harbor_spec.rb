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
            is_expected.to contain_archive('/tmp/harbor-offline-installer-v1.7.5.tgz').with(
              'source' => 'https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v1.7.5.tgz',
            )
          end
          it { is_expected.to contain_file('/opt/harbor-v1.7.5') }
          it { is_expected.to contain_file('/opt/harbor') }
          it { is_expected.to contain_docker__image('goharbor/harbor-log') }
        end
      end

      describe 'harbor::config' do
        context 'with init default params' do
          it do
            is_expected.to contain_file('/opt/harbor/harbor.cfg')
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
            is_expected.to contain_file('harbor_service_unit')
            is_expected.to contain_service('harbor')
          end
        end
      end
    end
  end
end
