class EmailsController < ApplicationController
  before_action :authenticate_user!

  def new
    @email = Email.new
  end

  def create
    @email = Email.new(email_params)
    @email.to = Settings.mailgun.admin_email
    @email.user_id = current_user.id if current_user.present?

    respond_to do |format|
      if @email.save && @email.deliver_now
        format.html { render :sent }
      else
        format.html { render :new }
      end
    end
  end

  private

  def email_params
    params.require(:email).permit(:from, :subject, :text)
  end
end
