# frozen_string_literal: true

# == Schema Information
#
# Table name: admins
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string(255)
#  invited_by_type        :string(255)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  name                   :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0)
#  site_admin             :boolean          default(FALSE), not null
#  created_at             :datetime
#  updated_at             :datetime
#  invited_by_id          :integer
#  team_id                :integer          not null
#
# Indexes
#
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_invitation_token      (invitation_token) UNIQUE
#  index_admins_on_invited_by_id         (invited_by_id)
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#  index_admins_on_team_id               (team_id)
#
FactoryBot.define do
  factory :admin do
    sequence :email do |n|
      "person#{n}@foo.com"
    end
    password { "password" }
    team
  end
end
