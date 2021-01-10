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

FactoryBot.define do
  factory :click_event do
    delivery_link_id { 1 }
    user_agent { "MyText" }
    referer { "MyText" }
    ip { "MyString" }
  end
end
