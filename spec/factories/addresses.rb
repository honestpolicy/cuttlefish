# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id         :bigint           not null, primary key
#  text       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_addresses_on_text  (text)
#
FactoryBot.define do
  factory :address do
    text { "matthew@foo.com" }
  end
end
