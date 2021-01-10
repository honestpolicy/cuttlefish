# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_links
#
#  id                 :bigint           not null, primary key
#  click_events_count :integer          default(0), not null
#  created_at         :datetime
#  updated_at         :datetime
#  delivery_id        :integer          not null
#  link_id            :integer          not null
#
# Indexes
#
#  index_delivery_links_on_delivery_id  (delivery_id)
#  index_delivery_links_on_link_id      (link_id)
#

FactoryBot.define do
  factory :delivery_link do
    delivery
    link
    click_events { [] }
  end
end
