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
class PostfixLogLine < ActiveRecord::Base
  belongs_to :delivery, inverse_of: :postfix_log_lines

  after_save :update_status!

  def dsn_class
    match = dsn.match(/^(\d)\.(\d+)\.(\d+)/)
    raise "Unexpected form for dsn code" if match.nil?

    match[1].to_i
  end

  def status
    if dsn_class == 2
      "delivered"
    elsif dsn_class == 4
      "soft_bounce"
    # Mailbox full should be treated as a temporary problem
    elsif dsn == "5.2.2"
      "soft_bounce"
    elsif dsn_class == 5
      "hard_bounce"
    else
      raise "Unknown dsn class"
    end
  end

  # My status has changed. Tell those effected.
  def update_status!
    delivery.save!
  end

  def self.create_from_line(line)
    values = match_main_content(line)
    return if values.nil?

    program = values.delete(:program)
    to = values.delete(:to)
    queue_id = values.delete(:queue_id)

    # Only log delivery attempts
    # Note that timeouts in connecting to the remote mail server appear in
    # the program "error". So, we're including those
    return unless %w[smtp error].include?(program)

    delivery = Delivery.joins(:email, :address)
                       .order("emails.created_at DESC")
                       .find_by(
                         "addresses.text" => to,
                         postfix_queue_id: queue_id
                       )

    if delivery
      a = values.merge(delivery_id: delivery.id)
      # Don't resave duplicates and return nil if it was a duplicate
      PostfixLogLine.create!(a) if PostfixLogLine.find_by(a).nil?
    else
      puts "Skipping address #{to} from postfix queue id #{queue_id} - " \
           "it's not recognised: #{line}"
    end
  end

  def self.match_main_content(line)
    # Assume the log file was written using syslog and parse accordingly
    # rubocop:disable Style/StringConcatenation
    p = SyslogProtocol.parse("<13>" + line)
    # rubocop:enable Style/StringConcatenation
    content_match =
      p.content.match %r{^postfix/(\w+)\[(\d+)\]: (([0-9A-F]+): )?(.*)}
    if content_match.nil?
      puts "Skipping unrecognised line: #{line}"
      return nil
    end

    program_content = content_match[5]
    to_match = program_content.match(/to=<([^>]+)>/)
    relay_match = program_content.match(/relay=([^,]+)/)
    delay_match = program_content.match(/delay=([^,]+)/)
    delays_match = program_content.match(/delays=([^,]+)/)
    dsn_match = program_content.match(/dsn=([^,]+)/)
    status_match = program_content.match(/status=(.*)$/)

    result = {
      time: p.time,
      program: content_match[1],
      queue_id: content_match[4]
    }
    result[:to] = to_match[1] if to_match
    result[:relay] = relay_match[1] if relay_match
    result[:delay] = delay_match[1] if delay_match
    result[:delays] = delays_match[1] if delays_match
    result[:dsn] = dsn_match[1] if dsn_match
    result[:extended_status] = status_match[1] if status_match

    result
  end
end
