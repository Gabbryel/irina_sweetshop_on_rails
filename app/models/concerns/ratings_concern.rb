module RatingsConcern
  extend ActiveSupport::Concern

  def ratings
    self.reviews.map { |rev| rev.rating if rev.approved }
  end
end