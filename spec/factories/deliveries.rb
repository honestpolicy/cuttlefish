# frozen_string_literal: true

# == Schema Information
#
# Table name: deliveries
#
#  id                :bigint           not null, primary key
#  open_events_count :integer          default(0), not null
#  open_tracked      :boolean          default(FALSE), not null
#  sent              :boolean          default(FALSE), not null
#  status            :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  address_id        :integer
#  app_id            :integer
#  email_id          :integer
#  postfix_queue_id  :string(255)
#
# Indexes
#
#  index_deliveries_on_address_id_and_created_at         (address_id,created_at)
#  index_deliveries_on_app_id                            (app_id)
#  index_deliveries_on_created_at_and_open_events_count  (created_at,open_events_count)
#  index_deliveries_on_email_id_and_address_id           (email_id,address_id)
#  index_deliveries_on_open_tracked_and_created_at       (open_tracked,created_at)
#  index_deliveries_on_postfix_queue_id                  (postfix_queue_id)
#
FactoryBot.define do
  factory :delivery do
    email
    address
  end
end
