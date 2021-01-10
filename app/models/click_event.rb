# frozen_string_literal: true

# == Schema Information
#
# Table name: click_events
#
#  id               :bigint           not null, primary key
#  ip               :string(255)
#  referer          :text
#  user_agent       :text
#  created_at       :datetime
#  updated_at       :datetime
#  delivery_link_id :integer
#
# Indexes
#
#  index_click_events_on_delivery_link_id  (delivery_link_id)
#
class ClickEvent < ActiveRecord::Base
  belongs_to :delivery_link, counter_cache: true
  delegate :link, to: :delivery_link
  include UserAgent

  def url
    link.url
  end
end
