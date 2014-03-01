module Merit
  # Sash is a container for reputation data for meritable models. It's an
  # indirection between meritable models and badges and scores (one to one
  # relationship).
  #
  # It's existence make join models like badges_users and scores_users
  # unnecessary. It should be transparent at the application.
  class Sash < ActiveRecord::Base
    include Base::Sash
    has_many :badges_sashes, dependent: :destroy
    has_many :scores, dependent: :destroy, class_name: 'Merit::Score'

    after_create :create_scores

    def add_badge(badge_id)
      bs = BadgesSash.new(badge_id: badge_id)
      badges_sashes << bs
      bs
    end

    def rm_badge(badge_id)
      badges_sashes.find_by_badge_id(badge_id).try(:destroy)
    end

    # Retrieve all points from a category or none if category doesn't exist
    # By default retrieve all Points
    # @param category [String] The category
    # @return [ActiveRecord::Relation] containing the points
    def score_points(options = {})
      scope = Merit::Score::Point
      .includes(:score)
      .where('merit_scores.sash_id = ?', id)
      if (category = options[:category])
        scope = scope.where('merit_scores.category = ?', category)
      end
      scope
    end
  end
end
