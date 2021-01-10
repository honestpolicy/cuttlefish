# frozen_string_literal: true

# == Schema Information
#
# Table name: deny_lists
#
#  id                            :bigint           not null, primary key
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  address_id                    :bigint           not null
#  app_id                        :bigint           not null
#  caused_by_postfix_log_line_id :bigint           not null
#
# Indexes
#
#  index_deny_lists_on_address_id                     (address_id)
#  index_deny_lists_on_app_id                         (app_id)
#  index_deny_lists_on_caused_by_postfix_log_line_id  (caused_by_postfix_log_line_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (app_id => apps.id)
#  fk_rails_...  (caused_by_postfix_log_line_id => postfix_log_lines.id)
#

FactoryBot.define do
  factory :deny_list do
    app
    address
    caused_by_postfix_log_line factory: :postfix_log_line
  end
end
