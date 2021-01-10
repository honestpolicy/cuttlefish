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
require "spec_helper"

describe App do
  describe "#smtp_password" do
    it "should create a password that is twenty characters long" do
      expect(create(:app).smtp_password.size).to eq 20
    end

    it "should create a password that is different every time" do
      expect(create(:app).smtp_password).to_not eq(
        create(:app).smtp_password
      )
    end
  end

  describe "#name" do
    it "should allow letters, numbers, spaces and underscores" do
      expect(build(:app, name: "Foo12 Bar_Foo")).to be_valid
    end

    it "should not allow other characters" do
      expect(build(:app, name: "*")).to_not be_valid
    end
  end

  describe "#smtp_username" do
    it "should set the smtp_username based on the name when created" do
      app = create(:app, name: "Planning Alerts", id: 15)
      expect(app.smtp_username).to eq "planning_alerts_15"
    end

    it "should not change the smtp_username if the name is updated" do
      app = create(:app, name: "Planning Alerts", id: 15)
      app.update_attributes(name: "Another description")
      expect(app.smtp_username).to eq "planning_alerts_15"
    end
  end

  describe "#custom_tracking_domain" do
    it "should look up the cname of the custom domain and check " \
       "it points to the cuttlefish server" do
      app = build(:app, custom_tracking_domain: "email.myapp.com")
      expect(App).to receive(:lookup_dns_cname_record)
        .with("email.myapp.com").and_return("localhost.")
      expect(app).to be_valid
    end

    it "should look up the cname of the custom domain and check " \
       "it points to the cuttlefish server" do
      app = build(:app, custom_tracking_domain: "email.foo.com")
      expect(App).to receive(:lookup_dns_cname_record)
        .with("email.foo.com").and_return("foo.com.")
      expect(app).to_not be_valid
    end

    it "should not look up the cname if the custom domain hasn't been set" do
      app = build(:app)
      expect(App).to_not receive(:lookup_dns_cname_record)
      expect(app).to be_valid
    end
  end

  describe "dkim validation" do
    let(:app) { create(:app, id: 12) }

    context "dkim disabled" do
      before(:each) { app.dkim_enabled = false }

      context "a from domain specified" do
        before(:each) { app.from_domain = "foo.com" }

        it "should be valid" do
          expect(app).to be_valid
        end
      end
    end

    context "dkim enabled" do
      before(:each) { app.dkim_enabled = true }

      context "no from domain specified" do
        it "should not be valid" do
          expect(app).to_not be_valid
        end

        it "should have a sensible error message" do
          app.valid?
          expect(app.errors.messages).to eq(
            dkim_enabled: ["can't be enabled if from_domain is not set"]
          )
        end
      end

      context "a from domain specified" do
        before(:each) { app.from_domain = "foo.com" }

        context "that has dns setup" do
          before(:each) do
            allow_any_instance_of(DkimDns).to receive(:dkim_dns_configured?) {
              true
            }
          end

          it "should be valid" do
            expect(app).to be_valid
          end
        end

        context "that has no dns setup" do
          before(:each) do
            allow_any_instance_of(DkimDns).to receive(:dkim_dns_configured?) {
              false
            }
          end

          it "should not be valid" do
            expect(app).to_not be_valid
          end

          it "should have an error message" do
            app.valid?
            expect(app.errors.messages).to eq(
              from_domain: [
                "doesn't have a DNS record configured correctly for " \
                "my_app_12.cuttlefish._domainkey.foo.com"
              ]
            )
          end
        end
      end
    end
  end

  describe "#tracking_domain_info" do
    let(:custom_tracking_domain) { nil }
    let(:app) { build(:app, custom_tracking_domain: custom_tracking_domain) }

    it "should by default return the cuttlefish domain and use https" do
      expect(app.tracking_domain_info).to eq(
        protocol: "https",
        domain: Rails.configuration.cuttlefish_domain
      )
    end

    context "with a custom tracking domain" do
      let(:custom_tracking_domain) { "foo.com" }

      it "should return the custom tracking domain and use http" do
        expect(app.tracking_domain_info).to eq(
          protocol: "http",
          domain: "foo.com"
        )
      end
    end

    context "in development environment" do
      before(:each) do
        allow(Rails).to receive_message_chain(:env, :development?) { true }
      end

      it "should return the localhost and use http" do
        expect(app.tracking_domain_info).to eq(
          protocol: "http",
          domain: "localhost:3000"
        )
      end
    end
  end

  describe "#dkim_private_key" do
    it "should be generated automatically" do
      app = create(:app)
      expect(app.dkim_private_key.to_pem.split("\n").first).to eq(
        "-----BEGIN RSA PRIVATE KEY-----"
      )
    end

    it "should be different for different apps" do
      app1 = create(:app)
      app2 = create(:app)
      expect(app1.dkim_private_key).to_not eq app2.dkim_private_key
    end

    it "should be saved in the database" do
      app = create(:app)
      value = app.dkim_private_key.to_pem
      app.reload
      expect(app.dkim_private_key.to_pem).to eq value
    end
  end

  describe "#dkim_selector" do
    let(:app) { create(:app, name: "Book store", id: 15) }

    it "should include the name and the id to be unique" do
      expect(app.dkim_selector).to eq "book_store_15.cuttlefish"
    end

    context "legacy dkim selector" do
      let(:app) { create(:app, legacy_dkim_selector: true) }
      it "should just be cuttlefish" do
        expect(app.dkim_selector).to eq "cuttlefish"
      end
    end
  end

  describe ".cuttlefish" do
    before(:each) do
      allow(Rails.configuration).to receive(:cuttlefish_domain)
        .and_return("cuttlefish.io")
    end
    let(:app) { App.cuttlefish }

    it { expect(app.name).to eq "Cuttlefish" }
    it { expect(app.from_domain).to eq "cuttlefish.io" }
    it { expect(app.team).to be_nil }

    it "should return the same instance when request twice" do
      expect(app.id).to eq App.cuttlefish.id
    end
  end

  describe "#open_tracking_enabled" do
    it "should not validate with nil value" do
      app = build(:app, open_tracking_enabled: nil)
      expect(app).to_not be_valid
    end
  end

  # The following two tests are commented out because they require a network
  # connection and are testing real things in DNS so in general it makes the
  # tests fragile. Though, if you're working on the lookup_dns_cname_record
  # method it's probably a good idea to uncomment them!

  # describe "#lookup_dns_cname_record" do
  #   it "should resolve the cname of www.openaustralia.org" do
  #     expect(App.lookup_dns_cname_record("www.openaustralia.org")).to eq(
  #       "kedumba.openaustralia.org."
  #     )
  #   end
  #
  #   it "should not resolve the cname of twiddlesticks.openaustralia.org" do
  #     expect(
  #       App.lookup_dns_cname_record("twiddlesticks.openaustralia.org")
  #     ).to be_nil
  #   end
  # end

  describe "#webhook_url" do
    it "should validate if the url returns 200 code from POST" do
      url = "https://www.planningalerts.org.au/deliveries"
      key = "abc123"
      expect(WebhookServices::PostTestEvent).to receive(:call).with(
        url: url, key: key
      )
      app = build(:app, webhook_url: url, webhook_key: key)
      expect(app).to be_valid
    end

    it "should validate with nil and not try to do a POST" do
      expect(WebhookServices::PostTestEvent).to_not receive(:call)
      app = build(:app, webhook_url: nil)
      expect(app).to be_valid
    end

    it "should not validate if the url returns a 404" do
      VCR.use_cassette("webhook") do
        app = build(
          :app,
          webhook_url: "https://www.planningalerts.org.au/deliveries"
        )
        expect(app).to_not be_valid
        expect(app.errors[:webhook_url]).to eq(
          ["returned 404 code when doing POST to https://www.planningalerts.org.au/deliveries"]
        )
      end
    end

    it "should not validate if the webhook can't connect" do
      expect(WebhookServices::PostTestEvent).to receive(:call).and_raise(
        SocketError.new("Failed to open TCP connection to foo:80 (getaddrinfo: Name or service not known)")
      )
      app = build(
        :app,
        webhook_url: "foo"
      )
      expect(app).to_not be_valid
      expect(app.errors[:webhook_url]).to eq(
        ["error when doing test POST to foo: " \
         "Failed to open TCP connection to foo:80 (getaddrinfo: Name or service not known)"]
      )
    end
  end
end
