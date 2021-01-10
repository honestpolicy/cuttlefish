# frozen_string_literal: true

# == Schema Information
#
# Table name: apps
#
#  id                        :bigint           not null, primary key
#  archived_deliveries_count :integer          default(0), not null
#  click_tracking_enabled    :boolean          default(TRUE), not null
#  custom_tracking_domain    :string(255)
#  cuttlefish                :boolean          default(FALSE), not null
#  dkim_enabled              :boolean          default(FALSE), not null
#  dkim_private_key          :text
#  from_domain               :string(255)
#  legacy_dkim_selector      :boolean          default(FALSE), not null
#  name                      :string(255)
#  open_tracking_enabled     :boolean          default(TRUE), not null
#  smtp_password             :string(255)
#  smtp_username             :string(255)
#  webhook_key               :string           not null
#  webhook_url               :string
#  created_at                :datetime
#  updated_at                :datetime
#  team_id                   :integer
#
# Indexes
#
#  index_apps_on_team_id  (team_id)
#
FactoryBot.define do
  factory :app do
    team
    name { "My App" }
  end
end
