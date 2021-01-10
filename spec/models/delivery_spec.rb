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
require "spec_helper"

describe Delivery do
  let(:delivery) { create(:delivery) }

  describe "#status" do
    context "delivery is sent" do
      before :each do
        delivery.update_attributes(sent: true)
      end

      it "should be delivered if the status is sent" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(
          dsn: "2.0.0",
          time: Time.now,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        expect(delivery.status).to eq "delivered"
      end

      it "should be soft_bounce if the status was deferred" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(
          dsn: "4.3.0",
          time: Time.now,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        expect(delivery.status).to eq "soft_bounce"
      end

      it "should be sent if there is no log line" do
        expect(delivery.status).to eq "sent"
      end

      it "should be delivered if most recent status was a succesful delivery" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(
          dsn: "4.3.0",
          time: 1.hour.ago,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        delivery.postfix_log_lines.create(
          dsn: "2.0.0",
          time: 5.minutes.ago,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        expect(delivery.status).to eq "delivered"
      end
    end

    it "should be not_sent if the nothing's been sent yet" do
      expect(delivery.status).to eq "not_sent"
    end

    it "should have a return path" do
      expect(delivery.return_path).to eq "bounces@cuttlefish.oaf.org.au"
    end
  end
end
