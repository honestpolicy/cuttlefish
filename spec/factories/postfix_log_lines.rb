# frozen_string_literal: true

# == Schema Information
#
# Table name: postfix_log_lines
#
#  id              :bigint           not null, primary key
#  delay           :string(255)      not null
#  delays          :string(255)      not null
#  dsn             :string(255)      not null
#  extended_status :text             not null
#  relay           :string(255)      not null
#  time            :datetime         not null
#  created_at      :datetime
#  updated_at      :datetime
#  delivery_id     :integer          not null
#
# Indexes
#
#  index_postfix_log_lines_on_delivery_id           (delivery_id)
#  index_postfix_log_lines_on_time_and_delivery_id  (time,delivery_id)
#
# Foreign Keys
#
#  postfix_log_lines_delivery_id_fk  (delivery_id => deliveries.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :postfix_log_line do
    delivery

    time { Time.now }
    relay { "foo.com[1.2.3.4]:25" }
    delay { "2.1" }
    delays { "0.09/0.02/0.99/0.99" }
    dsn { "2.0.0" }
    extended_status { "sent (250 ok dirdel)" }
  end
end
