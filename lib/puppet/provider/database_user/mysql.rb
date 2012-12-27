Puppet::Type.type(:database_user).provide(:mysql) do

  desc "manage users for a mysql database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def self.instances
    users = mysql("--defaults-file=%s" % @resource.value(:defaults_file), "mysql", '-BNe' "select concat(User, '@',Host) as User from mysql.user").split("\n")
    users.select{ |user| user =~ /.+@/ }.collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql("--defaults-file=%s" % @resource.value(:defaults_file), "mysql", "-e", "create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource.value(:password_hash) ])
  end

  def destroy
    mysql("--defaults-file=%s" % @resource.value(:defaults_file), "mysql", "-e", "drop user '%s'" % @resource.value(:name).sub("@", "'@'") )
  end

  def password
    @resource.value(:password)
  end

  def password=(string)
    phash = mysql_password(string)
    self.password_hash = phash
  end

  def password_hash
    mysql("--defaults-file=%s" % @resource.value(:defaults_file), "mysql", "-NBe", "select password from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).chomp
  end

  def password_hash=(string)
    mysql("--defaults-file=%s" % @resource.value(:defaults_file), "mysql", "-e", "SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ] )
  end

  def exists?
    not mysql("--defaults-file=%s" % @resource.value(:defaults_file), "mysql", "-NBe", "select '1' from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).empty?
  end

  def defaults_file
    @resource.value(:defaults_file)
  end

  def flush
    @property_hash.clear
    mysqladmin "--defaults-file=%s" % @resource.value(:defaults_file), "flush-privileges"
  end

end
