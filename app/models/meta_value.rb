# frozen_string_literal: true

# == Schema Information
#
# Table name: meta_values
#
#  id       :bigint           not null, primary key
#  key      :string           not null
#  value    :string           not null
#  email_id :bigint           not null
#
# Indexes
#
#  index_meta_values_on_email_id          (email_id)
#  index_meta_values_on_email_id_and_key  (email_id,key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (email_id => emails.id)
#
class MetaValue < ActiveRecord::Base
  belongs_to :email
end
