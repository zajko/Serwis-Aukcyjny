class UserSearch < Tableless
  column :birthday_gte
  column :birthday_lte
  column :login_like
  column :first_name_like
  column :surname_like
  column :last_login_ip_equals
  @roles
  @interests
  def roles_attributes=(atr)
    @roles = []
    @roles.push(atr)
  end
  def interests_attributes=(atr)
    @interests = []
    @interests.push(atr)
  end
  def interests
    @interests
  end
  def roles
    @roles
  end
end