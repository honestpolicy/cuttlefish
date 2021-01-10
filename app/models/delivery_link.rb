# frozen_string_literal: true

# == Schema Information
#
# Table name: delivery_links
#
#  id                 :bigint           not null, primary key
#  click_events_count :integer          default(0), not null
#  created_at         :datetime
#  updated_at         :datetime
#  delivery_id        :integer          not null
#  link_id            :integer          not null
#
# Indexes
#
#  index_delivery_links_on_delivery_id  (delivery_id)
#  index_delivery_links_on_link_id      (link_id)
#
class DeliveryLink < ActiveRecord::Base
  belongs_to :link
  belongs_to :delivery
  has_many :click_events, dependent: :destroy

  delegate :to, :subject, :app_name, to: :delivery

  def url
    link.url
  end

  def add_click_event(request)
    click_events.create!(
      user_agent: request.env["HTTP_USER_AGENT"],
      referer: request.referer,
      ip: request.remote_ip
    )
  end

  def clicked?
    !click_events.empty?
  end
end
