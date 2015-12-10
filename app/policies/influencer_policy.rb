class InfluencerPolicy < Struct.new(:user, :influencer)

#====== for authorizing influencer only tasks ===========
  def influencer?
    user.influencer?
  end
end