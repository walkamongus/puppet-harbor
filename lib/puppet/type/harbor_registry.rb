# frozen_string_literal: true
Puppet::Type.newtype(:harbor_registry) do
  desc 'Manage Harbor registry endpoints'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Name of the Registry'
  end

  newproperty(:description) do
  end

  newproperty(:url) do
  end

  newparam(:set_credential) do
    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:access_key) do
  end

  newparam(:access_secret) do
  end

  newproperty(:insecure) do
    defaultto :false
    newvalues(:true, :false)
  end
end
