class ErrorsController < ApplicationController

 skip_before_action :authenticate_user!

 def not_found
  skip_authorization
   respond_to do |format|
     format.html { render status: 404 }
   end
 rescue ActionController::UnknownFormat
   render status: 404, text: "nope"
 end
end