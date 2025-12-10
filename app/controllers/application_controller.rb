class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include MetaTagsConcern
  include Pagy::Backend
  include CurrentCartConcern
  
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: %i[index show]


  # Pundit: white-list approach.
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Handle Pundit authorization failures with a friendly page
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized(exception = nil)
    @policy_error = exception&.message || 'Nu ai permisiunea necesară pentru această acțiune.'
    respond_to do |format|
      format.html { render 'errors/access_denied', status: :forbidden }
      format.json { render json: { error: @policy_error }, status: :forbidden }
    end
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
