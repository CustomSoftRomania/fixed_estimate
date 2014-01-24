require 'spec_helper'

class Issue < ActiveRecord::Base
  has_many :time_entries

  def spent_hours
    @spent_hours = time_entries.sum(:hours) || 0
  end
end

class TimeEntry < ActiveRecord::Base
  include FixedEstimate
  belongs_to :issue
  belongs_to :activity, :class_name => 'TimeEntryActivity', :foreign_key => 'activity_id'
end

class TimeEntryActivity < ActiveRecord::Base
  has_many :time_entries, :foreign_key => 'activity_id'
end

describe "fixed_estimate" do
  before :each do
    @dev = TimeEntryActivity.create(:name => "Development")
    @design = TimeEntryActivity.create(:name => "Design")
  end

  it "should define check_fixed_estimate" do
    time_entry = TimeEntry.new
    time_entry.should respond_to(:check_fixed_estimate)
  end

  it "should create time entry if limit is < estimated_hours" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 9, activity: @dev)
    time_entry.save.should eql(true)
  end

  it "should create multiple time entries if limit is < estimated_hours" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 3.5, activity: @dev)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 6.5, activity: @dev)
    time_entry.save.should eql(true)
  end

  it "should not create time entry if limit is > estimated_hours" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 12, activity: @dev)
    time_entry.save.should eql(false)
    time_entry.errors[:hours].count.should eql(1)
  end

  it "should not create time entry if limit is > estimated_hours with multiple entries" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 7, activity: @dev)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 5, activity: @dev)
    time_entry.save.should eql(false)
    time_entry.errors[:hours].count.should eql(1)
  end

  it "does create time entry when estimated hours is nil" do
    issue = Issue.create(name: "Test", estimated_hours: nil)
    time_entry = TimeEntry.new(issue: issue, hours: 7, activity: @dev)
    time_entry.save.should eql(true)
  end

  it "does create a time entry for development if design + dev > estimated time but current dev + dev <= estimated time" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 7, activity: @design)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 5, activity: @dev)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 6.5, activity: @dev)
    time_entry.save.should eql(false)
  end

  it "should allow design time entry if development is full" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 4, activity: @dev)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 6, activity: @dev)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 7, activity: @design)
    time_entry.save.should eql(true)
  end

  it "should allow to add up to 10% more" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 4, activity: @dev)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 7, activity: @dev)
    time_entry.save.should eql(true)
  end

  it "should not allow to add up to 10.01% more" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 4, activity: @dev)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 7.01, activity: @dev)
    time_entry.save.should eql(false)
  end
end
