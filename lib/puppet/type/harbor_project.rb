# frozen_string_literal: true

Puppet::Type.newtype(:harbor_project) do
  desc 'Manage Harbor projects'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Name of the project'
  end

  newproperty(:public) do
    defaultto :false
    newvalues(:true, :false)
  end

  newproperty(:members, array_matching: :all) do
    def insync?(is)
      is.sort == should.sort
    end
  end
end
