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
FactoryBot.define do
  factory :open_event do
  end
end
