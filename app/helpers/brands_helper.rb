module BrandsHelper
  def category_list
    results = []

    User.find_in_batches(batch_size: 500) do |user_group|
      user_group.each { |user| results << user.industry }
    end

    results.compact.uniq.sort
  end
end
