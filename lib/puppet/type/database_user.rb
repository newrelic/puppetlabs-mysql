# This has to be a separate type to enable collecting
Puppet::Type.newtype(:database_user) do
  @doc = "Manage a database user. This includes management of users password as well as priveleges"

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the user. This uses the 'username@hostname' or username@hostname."
    validate do |value|
      # https://dev.mysql.com/doc/refman/5.1/en/account-names.html
      # Regex should problably be more like this: /^[`'"]?[^`'"]*[`'"]?@[`'"]?[\w%\.]+[`'"]?$/
      raise(ArgumentError, "Invalid database user #{value}") unless value =~ /[\w-]*@[\w%\.:]+/
      username = value.split('@')[0]
      if username.size > 16
        raise ArgumentError, "MySQL usernames are limited to a maximum of 16 characters"
      end
    end
  end

  newproperty(:password_hash) do
    desc "The password hash of the user. Use mysql_password() for creating such a hash."
    newvalue(/\w+/)
  end

  newproperty(:password) do
    desc "The password of the user"
    newvalue(/\w+/)
  end

  newproperty(:defaults_file) do
    desc "Defaults file to use for connection to the database"
    defaultto '/root/.my.cnf'
  end

  newproperty(:max_user_connections) do
    desc "Set the number of connections max for a user"
    defaultto 0
  end

  newproperty(:max_queries_per_hour) do
    desc "Set the number of maximum queries per hour for a user"
    defaultto 0
  end

  newproperty(:max_updates_per_hour) do
    desc "Set the number of maximum updates per hour for a user"
    defaultto 0
  end

  newproperty(:max_connections_per_hour) do
    desc "Set the number of maximum connections per hour for a user"
    defaultto 0
  end
end
