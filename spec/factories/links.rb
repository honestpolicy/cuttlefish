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

FactoryBot.define do
  factory :link do
    url { "http://foo.com" }
  end
end
