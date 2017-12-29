if defined?(ChefSpec)

  def add_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :set, resource_name)
  end

  def delete_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :delete, resource_name)
  end

  def modify_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :modify, resource_name)
  end

  def addormodify_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :addormodify, resource_name)
  end

end
