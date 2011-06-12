# +grant_on+ accepts:
# * Nothing (always grants)
# * A block which evaluates to boolean (recieves the object as parameter)
# * A block with a hash composed of methods to run on the target object with
#   expected values (+:votes => 5+ for instance).
#
# +grant_on+ can have a +:to+ method name, which called over the target object
# should retrieve the object to badge (could be +:user+, +:self+, +:follower+,
# etc). If it's not defined talent will apply the badge to the user who
# triggered the action (:action_user by default). If it's :itself, it badges
# the created object (new user for instance).
#
# The :temporary option indicates that if the condition doesn't hold but the
# badge is granted, then it's removed. It's false by default (badges are kept
# forever).

class TalentRules
  include Talent::Rules

  def initialize
    # If it creates user, grant badge
    # Should be "current_user" after registration for badge to be granted.
    grant_on 'users#create', :badge => 'just-registered', :to => :itself

    # If it has 10 comments, grant commenter-10 badge
    grant_on 'comments#create', :badge => 'commenter', :level => 10 do
      { :user => { :comments => { :count => 10 } } }
    end

    # If it has at least 10 votes, grant relevant-commenter badge
    grant_on 'comments#vote', :badge => 'relevant-commenter', :to => :user do |comment|
      comment.votes >= 10
    end

    # Changes his name by one wider than 4 chars (arbitrary ruby code case)
    # This badge is temporary (user may lose it)
    grant_on 'users#update', :badge => 'autobiographer', :temporary => true do |user|
      user.name.length > 4
    end
  end
end