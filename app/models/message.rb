class Message < ActiveRecord::Base
  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  belongs_to :campaign
  has_many :images

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :sender_id, :receiver_id, presence: true

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  after_create :send_message_through_pubnub

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------
  private

  def send_message_through_pubnub
    subscriber_chanels = User.where(id: [ sender_id, receiver_id]).pluck(:channel_name)
    sender_profile_picture_url = User.find(sender_id).profile_picture

    Rails.logger.info 'Send pubnub notification for message creation'
    Rails.logger.info subscriber_chanels

    attach_image_urls = images.map{|image| image.image_path.url }

    subscriber_chanels.each do |channel|
      Rails.logger.info channel
      $pubnub_server_subscription.publish(
          :channel => channel,
          :message => {event: 'MESSAGE',
                       attributes: {
                           id: self.id,
                           body: self.body,
                           sender_id: self.sender_id,
                           receiver_id: self.receiver_id,
                           campaign_id: self.campaign_id,
                           sender_profile_picture_url: sender_profile_picture_url,
                           image_urls: attach_image_urls
                       }
          },
          callback: lambda{ |info| Rails.logger.info 'Send message to pubnub channel' + info }
      )
    end
  end

  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------
end
