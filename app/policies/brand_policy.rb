class AdminPolicy < Struct.new(:user, :brand)

#====== for authorizing brand only tasks ===========
  def brand?
    user.brand?
  end
end