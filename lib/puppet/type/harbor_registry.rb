# frozen_string_literal: true

Puppet::Type.newtype(:harbor_registry) do
  desc <<-DESC
@summary Manage Harbor registry endpoints

@example Creating a registry within Harbor
    harbor_registry { 'my-registry':
      ensure         => present,
      url            => 'https://registry.example.org',
      description    => 'Upstream registry',
      set_credential => 'true',
      access_key     => 'admin',
      access_secret  => $encrypted_password,
    }
DESC

  ensurable

  newparam(:name, namevar: true) do
    desc 'The registry name'
  end

  newproperty(:description) do
    desc 'Description of the registry'
  end

  newproperty(:url) do
    desc 'The registry URL string'
  end

  newparam(:set_credential) do
    desc 'Whether to set the credential for the registry'
    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:access_key) do
    desc 'The access key or username for the registry if using `set_credential`'
  end

  newparam(:access_secret) do
    desc 'The secret or password for the registry if using `set_credential`'
  end

  newproperty(:insecure) do
    desc 'Whether or not the certificate will be verified when Harbor tries to access the server'
    defaultto :false
    newvalues(:true, :false)
  end
end
