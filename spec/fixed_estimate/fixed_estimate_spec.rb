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
end

describe "fixed_estimate" do
  it "should define check_fixed_estimate" do
    time_entry = TimeEntry.new
    time_entry.should respond_to(:check_fixed_estimate)
  end

  it "should create time entry if limit is < estimated_hours" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 9)
    time_entry.save.should eql(true)
  end

  it "should create multiple time entries if limit is < estimated_hours" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 3.5)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 6.5)
    time_entry.save.should eql(true)
  end

  it "should not create time entry if limit is > estimated_hours" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 11)
    time_entry.save.should eql(false)
    time_entry.errors[:hours].count.should eql(1)
  end

  it "should not create time entry if limit is > estimated_hours with multiple entries" do
    issue = Issue.create(name: "Test", estimated_hours: 10)
    time_entry = TimeEntry.new(issue: issue, hours: 7)
    time_entry.save.should eql(true)
    time_entry = TimeEntry.new(issue: issue, hours: 4)
    time_entry.save.should eql(false)
    time_entry.errors[:hours].count.should eql(1)
  end

  it "does create time entry when estimated hours is nil" do
    issue = Issue.create(name: "Test", estimated_hours: nil)
    time_entry = TimeEntry.new(issue: issue, hours: 7)
    time_entry.save.should eql(true)
  end
end
