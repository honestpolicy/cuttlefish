# frozen_string_literal: true

# == Schema Information
#
# Table name: deliveries
#
#  id                :bigint           not null, primary key
#  open_events_count :integer          default(0), not null
#  open_tracked      :boolean          default(FALSE), not null
#  sent              :boolean          default(FALSE), not null
#  status            :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  address_id        :integer
#  app_id            :integer
#  email_id          :integer
#  postfix_queue_id  :string(255)
#
# Indexes
#
#  index_deliveries_on_address_id_and_created_at         (address_id,created_at)
#  index_deliveries_on_app_id                            (app_id)
#  index_deliveries_on_created_at_and_open_events_count  (created_at,open_events_count)
#  index_deliveries_on_email_id_and_address_id           (email_id,address_id)
#  index_deliveries_on_open_tracked_and_created_at       (open_tracked,created_at)
#  index_deliveries_on_postfix_queue_id                  (postfix_queue_id)
#
class Delivery < ActiveRecord::Base
  belongs_to :email
  belongs_to :address
  has_many :postfix_log_lines, -> { order "time DESC" }, inverse_of: :delivery
  has_many :open_events, -> { order "created_at" }, dependent: :destroy
  has_many :delivery_links, dependent: :destroy
  has_many :links, through: :delivery_links
  has_many :click_events, -> { order "created_at" }, through: :delivery_links
  belongs_to :app

  delegate :from, :from_address, :from_domain, :text_part, :html_part, :data,
           :click_tracking_enabled?, :open_tracking_enabled?, :subject,
           :ignore_deny_list, :meta_values, :message_id,
           to: :email

  delegate :tracking_domain_info, to: :app

  before_save :update_my_status!
  before_create :update_app_id!

  scope :from_address,
        ->(address) { joins(:email).where(emails: { from_address: address }) }
  scope :to_address, ->(address) { where(address: address) }

  # Should this email be sent to this address?
  # If not it's because the email has bounced
  def send?
    email.ignore_deny_list || DenyList.find_by(app: app, address: address).nil?
  end

  def add_open_event(request)
    open_events.create!(
      user_agent: request.env["HTTP_USER_AGENT"],
      referer: request.referer,
      ip: request.remote_ip
    )
  end

  def calculated_status
    if sent?
      last_line = postfix_log_lines.first
      last_line ? last_line.status : "sent"
    else
      "not_sent"
    end
  end

  def update_my_status!
    self.status = calculated_status
  end

  def update_app_id!
    self.app_id = email.app_id
  end

  def to
    address.text
  end

  def return_path
    Rails.configuration.cuttlefish_bounce_email
  end

  def opened?
    !open_events.empty?
  end

  def clicked?
    delivery_links.any?(&:clicked?)
  end

  def clicked_lazy?
    BatchLoader.for(id).batch(default_value: false) do |ids, loader|
      delivery_links_map = {}
      DeliveryLink.where(delivery_id: ids).each do |d|
        delivery_links_map[d.delivery_id] ||= []
        delivery_links_map[d.delivery_id] << d
      end
      delivery_links_map.each do |id, delivery_links|
        clicked = delivery_links.any?(&:clicked?)
        loader.call(id, clicked)
      end
    end
  end

  def app_name
    app.name
  end

  # A value between 0 and 1. The fraction of deliveries with open tracking
  # for which the delivery was opened. Returns nil when there are no
  # deliveries with open tracking (which would otherwise cause a division by
  # zero error)
  def self.open_rate(deliveries)
    n = deliveries.where("open_events_count > 0").count
    total = deliveries.where(open_tracked: true).count
    (n.to_f / total) if total.positive?
  end

  def self.click_rate(deliveries)
    # By doing an _inner_ join we only end up counting deliveries that
    # have click_events
    n = deliveries.joins(:delivery_links).where("click_events_count > 0")
                  .select("distinct(deliveries.id)").count
    total = deliveries.joins(:delivery_links)
                      .select("distinct(deliveries.id)").count
    (n.to_f / total) if total.positive?
  end

  def self.stats(deliveries)
    OpenStruct.new(
      total_count: deliveries.count || 0,
      delivered_count:
        deliveries.group("deliveries.status").count["delivered"] || 0,
      soft_bounce_count:
        deliveries.group("deliveries.status").count["soft_bounce"] || 0,
      hard_bounce_count:
        deliveries.group("deliveries.status").count["hard_bounce"] || 0,
      not_sent_count:
        deliveries.group("deliveries.status").count["not_sent"] || 0,
      open_rate: open_rate(deliveries),
      click_rate: click_rate(deliveries)
    )
  end

  def content_available?
    !data.nil?
  end
end
