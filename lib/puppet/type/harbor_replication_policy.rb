# frozen_string_literal: true

Puppet::Type.newtype(:harbor_replication_policy) do
  desc 'Manage Harbor replication policies'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Name of policy'
  end

  newproperty(:description) do
    defaultto ""
  end

  newproperty(:src_registry) do
  end

  newproperty(:dest_registry) do
  end

  newproperty(:dest_namespace) do
  end

  newproperty(:trigger) do
  end

  newproperty(:filters) do
  end

  newproperty(:deletion) do
  end

  newproperty(:override) do
  end

  newproperty(:enabled) do
  end
end
