# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id               :bigint           not null, primary key
#  data_hash        :string(255)
#  ignore_deny_list :boolean          not null
#  subject          :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  app_id           :integer          not null
#  from_address_id  :integer
#  message_id       :string(255)
#
# Indexes
#
#  index_emails_on_app_id           (app_id)
#  index_emails_on_created_at       (created_at)
#  index_emails_on_from_address_id  (from_address_id)
#  index_emails_on_message_id       (message_id)
#
# Foreign Keys
#
#  emails_app_id_fk           (app_id => apps.id) ON DELETE => cascade
#  emails_from_address_id_fk  (from_address_id => addresses.id)
#
FactoryBot.define do
  factory :email do
    app
    ignore_deny_list { false }
  end
end
