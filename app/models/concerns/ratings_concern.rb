module RatingsConcern
  extend ActiveSupport::Concern

  def ratings
    self.reviews.map { |rev| rev.rating if rev.approved }
    .filter { |el| el if el != nil}
  end
end