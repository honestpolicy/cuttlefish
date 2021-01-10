# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  created_at :datetime
#  updated_at :datetime
#
class Team < ActiveRecord::Base
  has_many :admins
  has_many :apps
end
