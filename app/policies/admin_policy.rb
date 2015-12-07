class AdminPolicy < Struct.new(:user, :admin)

#====== for authorizing super admin tasks ===========
  def manage_admins?
    user.super_admin?
  end

#====== for authorizing super admin and admin common tasks ========
  def manage_brandreach?
    user.admin? || user.super_admin?
  end
end