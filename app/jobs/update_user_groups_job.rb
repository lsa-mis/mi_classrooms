class UpdateUserGroupsJob < ApplicationJob
  include LdapLookup
  queue_as :default

  def perform(*args)
    # Do something later
    user = arguments.first
    user.mcommunity_groups = user_group_memberships(user.uniqname).sort.to_json
    user.save
  end
end
