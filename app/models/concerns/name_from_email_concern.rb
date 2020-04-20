module NameFromEmailConcern
  extend ActiveSupport::Concern

  def name_from_mail
    self.email.split('@').first
  end

end