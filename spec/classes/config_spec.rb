# frozen_string_literal: true

require 'spec_helper'

describe 'harbor' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'harbor::config' do
        context 'with init default params' do
          it do
            is_expected.to contain_file('/opt/harbor/harbor.yml').with_content(/^_version: 2.8.0$/)
            is_expected.to contain_exec('migrate_cfg').with(
              'cwd' => '/opt/harbor',
              'command' => "/usr/bin/docker run --rm -v /:/hostfs goharbor/prepare:v2.8.2 migrate -i /opt/harbor-v2.8.2/harbor/harbor.yml"
            )
          end
        end
      end
    end
  end
end
