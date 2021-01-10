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
class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  belongs_to :team

  def display_name
    if name.present?
      name
    else
      email
    end
  end

  # Invite a new user to join the team of the inviting admin. It sends out
  # an invitation email
  def self.invite_to_team!(email:, inviting_admin:, accept_url:)
    Admin.invite!(
      { email: email, team_id: inviting_admin.team_id },
      inviting_admin,
      accept_url: accept_url
    )
  end

  # Overriding the implementation provided by devise so that we can pass
  # extra options to the mailer
  # Attempt to find a user by its email. If a record is found, send new
  # password instructions to it. If user is not found, returns a new user
  # with an email not found error.
  # Attributes must contain the user's email
  def self.send_reset_password_instructions(attributes = {}, mailer_options = {})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions(mailer_options) if recoverable.persisted?
    recoverable
  end

  # Overriding the implementation provided by devise so that we can pass
  # extra options to the mailer
  # Resets reset password token and send reset password instructions by email.
  # Returns the token sent in the e-mail.
  def send_reset_password_instructions(mailer_options = {})
    token = set_reset_password_token
    send_reset_password_instructions_notification(token, mailer_options)

    token
  end

  protected

  # Overriding the implementation provided by devise so that we can pass
  # extra options to the mailer
  def send_reset_password_instructions_notification(token, mailer_options = {})
    send_devise_notification(:reset_password_instructions, token, mailer_options)
  end
end
