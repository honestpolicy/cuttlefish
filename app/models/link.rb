# frozen_string_literal: true

# == Schema Information
#
# Table name: links
#
#  id         :bigint           not null, primary key
#  url        :string           not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_links_on_url  (url)
#
class Link < ActiveRecord::Base
  has_many :click_events, through: :delivery_links
  has_many :delivery_links
  has_many :deliveries, through: :delivery_links
end
