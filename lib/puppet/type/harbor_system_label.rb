# frozen_string_literal: true

Puppet::Type.newtype(:harbor_system_label) do
  desc 'Manage Harbor system labels'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Name of Label'
  end

  newproperty(:description) do
    defaultto ""
  end

  newproperty(:color) do
    defaultto "#FFFFFF"
  end
end
