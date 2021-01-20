# frozen_string_literal: true

require 'spec_helper'

describe 'harbor' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'harbor::config' do
        context 'with init default params' do
          it do
            is_expected.to contain_file('/opt/harbor/harbor.yml').with_content(/^_version: 2.1.0$/)
            is_expected.to contain_exec('migrate_cfg').with(
              'cwd' => '/opt/harbor',
              'command' => "/usr/bin/docker run --rm -v /:/hostfs goharbor/prepare:v2.1.2 migrate -i /opt/harbor-v2.1.2/harbor/harbor.yml"
            )
          end
        end
        context 'with harbor version < 2.0.0' do
          let(:params) { {'version' => '1.10.6'} }
          it do
            is_expected.to contain_file('/opt/harbor/harbor.yml').with_content(/^_version: 1.10.0$/)
            is_expected.to contain_exec('migrate_cfg').with(
              'cwd' => '/opt/harbor',
              'command' => "/usr/bin/docker run --rm -v harbor.yml:/harbor-migration/harbor-cfg/harbor.yml -v harbor.yml:/harbor-migration/harbor-cfg-out/harbor.yml goharbor/harbor-migrator:v1.10.0 --cfg up"
            )
          end
        end
      end
    end
  end
end
