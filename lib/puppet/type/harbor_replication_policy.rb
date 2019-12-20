# frozen_string_literal: true

Puppet::Type.newtype(:harbor_replication_policy) do
  desc 'Manage Harbor replication policies'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Name of policy'
  end

  newproperty(:description) do
    defaultto ''
  end

  newparam(:replication_mode) do
    newvalues(:push, :pull)
  end

  newparam(:remote_registry) do
    desc 'Name of registry to push to/pull from'
  end

  newproperty(:dest_namespace) do
  end

  newproperty(:trigger) do
  end

  newproperty(:filters, array_matching: :all) do
  end

  newproperty(:deletion) do
  end

  newproperty(:override) do
  end

  newproperty(:enabled) do
  end
end
