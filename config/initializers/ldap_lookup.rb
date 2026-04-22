LdapLookup.configuration do |config|
  config.host = ENV["LDAP_HOST"] || "ldap.umich.edu"
  config.port = ENV["LDAP_PORT"] || "389"
  config.base = ENV["LDAP_BASE"] || "dc=umich,dc=edu"
  # Leave username/password unset for anonymous binds
  config.username = ENV["LDAP_USERNAME"]
  config.password = ENV["LDAP_PASSWORD"]
  # Service account bind DN (preferred for UM LDAP)
  config.bind_dn = ENV["LDAP_BIND_DN"]
  # Read encryption from ENV, default to start_tls
  encryption_str = ENV["LDAP_ENCRYPTION"] || "start_tls"
  config.encryption = encryption_str.to_sym
  config.dept_attribute = ENV["LDAP_DEPT_ATTRIBUTE"] || "umichPostalAddressData"
  config.group_attribute = ENV["LDAP_GROUP_ATTRIBUTE"] || "umichGroupEmail"
  # Optional diagnostic UID (used by LdapLookup.test_connection)
  config.diagnostic_uid = ENV["LDAP_DIAGNOSTIC_UID"] if ENV["LDAP_DIAGNOSTIC_UID"]
  # Optional search bases for UM LDAP
  config.user_base = ENV["LDAP_USER_BASE"] if ENV["LDAP_USER_BASE"]
  config.group_base = ENV["LDAP_GROUP_BASE"] if ENV["LDAP_GROUP_BASE"]
  # Enable LDAP debug logging in this test runner
  debug_str = ENV["LDAP_DEBUG"]
  config.debug = debug_str ? debug_str.to_s.downcase == "true" : false
end
