# frozen_string_literal: true

# == Schema Information
#
# Table name: open_events
#
#  id          :bigint           not null, primary key
#  ip          :string(255)
#  os_family   :string(255)
#  os_version  :string(255)
#  referer     :text
#  ua_family   :string(255)
#  ua_version  :string(255)
#  user_agent  :text
#  created_at  :datetime
#  updated_at  :datetime
#  delivery_id :integer
#
# Indexes
#
#  index_open_events_on_delivery_id  (delivery_id)
#
class OpenEvent < ActiveRecord::Base
  belongs_to :delivery, counter_cache: true
  include UserAgent

  before_save :parse_user_agent!

  def parse_user_agent!
    self.ua_family = calculate_ua_family
    self.ua_version = calculate_ua_version
    self.os_family = calculate_os_family
    self.os_version = calculate_os_version
  end
end
