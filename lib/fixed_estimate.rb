module FixedEstimate
  extend ActiveSupport::Concern

  def self.included(base)
    base.send(:before_validation, :check_fixed_estimate)
  end

  def check_fixed_estimate
    if !issue.estimated_hours.nil? && issue.spent_hours + self.hours > issue.estimated_hours
      self.errors.add(:hours, "You cannot enter time_entries above estimated hours limit")
    end
  end
end

# if defined? Redmine
#   TimeEntry.send :include, FixedEstimate
# end
