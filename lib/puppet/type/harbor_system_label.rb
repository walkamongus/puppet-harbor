# frozen_string_literal: true

Puppet::Type.newtype(:harbor_system_label) do
  desc <<-DESC
@summary Manage Harbor system labels

@example Creating a system-level label within Harbor
    harbor_system_label { 'foo':
      ensure      => 'present',
      description => "Black text on white background label",
      color       => '#FFFFFF',
    }
DESC

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of label'
  end

  newproperty(:description) do
    desc 'The description of label'
    defaultto ''
  end

  newproperty(:color) do
    desc 'The color of label'
    defaultto '#FFFFFF'
  end
end
