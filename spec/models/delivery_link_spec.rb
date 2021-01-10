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
require "spec_helper"

describe DeliveryLink do
  describe "#add_click_event" do
    it "should log the link event with some info from the current request" do
      request = double(
        "Request",
        env: { "HTTP_USER_AGENT" => "some user agent info" },
        referer: "http://foo.com",
        remote_ip: "1.2.3.4"
      )
      delivery_link = create(:delivery_link)
      delivery_link.add_click_event(request)
      expect(delivery_link.click_events.count).to eq 1
      e = delivery_link.click_events.first
      expect(e.user_agent).to eq "some user agent info"
      expect(e.referer).to eq "http://foo.com"
      expect(e.ip).to eq "1.2.3.4"
    end
  end
end
