class OffersController < ApplicationController
  before_action :set_offer, only: [:accept, :deny, :undo_deny,
                                   :reply_message, :make_messages_read, :load_offer]

  # =====================================
  # we are referring campaign as offer for this page.
  # =====================================

  def index
      @offers = Campaign.active_offers(current_user).includes(:messages).order('messages.created_at desc')
      @stared_offers =  Campaign.stared_offers(current_user).includes(:messages).order('messages.created_at desc')
  end

  # take array of offer ids and make those stared
  #  target_column may be 'starred_by_brand' of 'starred_by_influencer'
  def toggle_star
    target_column = current_user.brand? ? :starred_by_brand : :starred_by_influencer
    @ids = params[:ids].map(&:to_i)
    offers = Campaign.where(id: @ids)

    @reset = nil

    if offers.count == offers.where(target_column => true).count
      # all offers are stared
      reset_star(offers, target_column)
      @reset = true
    elsif offers.count == offers.where(target_column => false).count
      # all offers are non stared
      set_star(offers, target_column)
    else
      # make all stared
      set_star(offers, target_column)
    end
  end

  def accept
    if offer_active?(params[:id])
      if @offer.waiting?
        @offer.update_attribute(:status, Campaign.statuses[:accepted])

        # populated offer accept message
        band_name = "<a href='/#{@offer.sender.id}/show_user' data-remote='true'>#{@offer.sender.full_name}</a>"
        message = "Hi #{band_name}, I accept your offer, Please go ahead and engage me for the campaign"
        @offer.messages.create({sender_id: current_user.id, receiver_id: @offer.sender.id,
                                body: message})

        # send email accept message
        CampaignMailer.campaign_accept_notification(@offer).deliver_now if @offer.sender.email_remainder_active?
      else
        @success = false
        @message = 'You can not perform accept operation to your selected offer'
      end
    end
  end

  def deny
    if offer_active?(params[:id])
      if @offer.waiting?
        @offer.update_attributes({status: Campaign.statuses[:denied], denied_at: Time.now })

        # populated offer deny message
        band_name = "<a href='/#{@offer.sender.id}/show_user' data-remote='true'>#{@offer.sender.full_name}</a>"
        message = "Hi #{band_name}, I am so sorry I can't accept your offer. Thank for your offer."
        @offer.messages.create({sender_id: current_user.id, receiver_id: @offer.sender.id,
                                body: message})

        # send email deny message
        CampaignMailer.campaign_deny_notification(@offer).deliver_now if @offer.sender.email_remainder_active?
      else
        @success = false
        @message = 'You can not perform deny operation to your selected offer'
      end
    end
  end

  def undo_deny
    if offer_active?(params[:id])
      if @offer.denied? && @offer.deny_undo_able?
        @offer.update_attribute(:status, Campaign.statuses[:waiting])

        # populated offer undo_deny message
        band_name = "<a href='/#{@offer.sender.id}/show_user' data-remote='true'>#{@offer.sender.full_name}</a>"
        message = "Hi #{band_name}, I changed my mind. I undo deny offer."
        @offer.messages.create({sender_id: current_user.id, receiver_id: @offer.sender.id,
                                body: message})

        # send email undo_deny message
        CampaignMailer.campaign_deny_undo_notification(@offer).deliver_now if @offer.sender.email_remainder_active?
      else
        @success = false
        @message = 'You can not perform deny_undo operation to your selected offer'
      end
    end
  end

  def reply_message
    if @offer && @offer.messageable?
      message = @offer.messages.new(sender_id: current_user.id, receiver_id: params[:receiver_id], body: params[:body])
      Rails.logger.info "Your message is #{message.body}"
      message.image_ids = params[:attach_iamge_ids].split(',').select(&:present?).map(&:to_i)

      if message.save
        success = true
        id = @offer.id
      else
        success = false
        id = @offer.id
      end

      respond_to do |format|
        format.json { render :json => {success: success, id: id, offer_id: @offer.id }}
      end
    end
  end

  def make_messages_read
    if @offer
      @offer.messages.where(receiver_id: current_user.id, read: false).update_all(:read => true)
      unreadMessages = current_user.unread_messages

      respond_to do |format|
        format.json { render :json => { id: @offer.id, unreadMessages: unreadMessages }}
      end
    end
  end

  def delete_offers
    target_column = current_user.brand? ? :deleted_by_brand : :deleted_by_influencer
    @engage_offer_select = false
    @ids = params[:ids].map(&:to_i)

    Rails.logger.info "Delet offer with ids #{@ids.inspect}"

    # check where engage offer selected for delete or not
    if Campaign.active_offers(current_user).where(id: @ids).where(status: Campaign.statuses[:engaged]).count > 0
      @engage_offer_select = true
    end

    offers = Campaign.active_offers(current_user).where(id: @ids).where.not(status: Campaign.statuses[:engaged])
    logger.info "Deleted offers are #{offers.count}"

    @ids = offers.pluck(:id)
    logger.info "Offer count after pluck #{offers.count}"

    offers.update_all(target_column => true)
    logger.info "Offer count after update_all #{offers.count}"

    @ids.each do |id|
      Campaign.find(id).save
    end

    Rails.logger.info "Delet offer with ids #{@ids.inspect}"
    current_user.received_messages.where(campaign_id: @ids).update_all(read: true)
    @unread_messages_count = current_user.received_messages.where(read: false).count
  end

  # load new incoming offer to offer page
  def load_offer
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_offer
    @offer = Campaign.active_offers(current_user).includes(:messages).order('messages.created_at desc').where(id: params[:id]).first
  end

  def offer_params
    params[:campaign]
  end

  def message_params
    params.require(:user).permit(:body, :sender_id, :receiver_id, :campaign_id)
  end

  def set_star(offers, target_column)
    offers.update_all(target_column => true)
  end

  def reset_star(offers, target_column)
    offers.update_all(target_column => false)
  end

  def offer_active?(offer_id)
    offer = Campaign.active_offers(current_user).where(id: offer_id).first
    if offer.present?
      @success = true
      true
    else
      @success = false
      @offer_id = offer_id
      @message = 'Your selected offer was deleted by sender/yourself.'
      false
    end
  end

  def can_send_message?
    !(@offer.deleted_by_influencer? || @offer.deleted_by_brand? || @offer.waiting? || @offer.denied?)
  end

end
