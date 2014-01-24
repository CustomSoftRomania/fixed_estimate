module FixedEstimate
  extend ActiveSupport::Concern

  def self.included(base)
    base.send(:before_validation, :check_fixed_estimate)
  end

  def check_fixed_estimate
    return if activity.name != "Development"

    return if issue.estimated_hours.nil?

    @dev_activity = TimeEntryActivity.find_by_name("Development")

    @dev_hours = issue.time_entries.where(:activity_id => @dev_activity.id).map(&:hours).inject(&:+) || 0
    if @dev_hours + self.hours > issue.estimated_hours * 1.1
      self.errors.add(:hours, "You cannot enter time_entries above estimated hours limit")
    end
  end
end

# if defined? Redmine
#   TimeEntry.send :include, FixedEstimate
# end
