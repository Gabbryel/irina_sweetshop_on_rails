class ErrorsController < ApplicationController

 skip_before_action :authenticate_user!

 def not_found
  skip_authorization
   respond_to do |format|
     format.html { render plain: 'Not found', status: :not_found }
     format.json { render json: { error: 'Not found' }, status: :not_found }
     format.any  { head :not_found }
   end
 rescue ActionController::UnknownFormat
   render status: 404, text: "nope"
 end
end