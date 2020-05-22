module MetaTagsConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_title
  end

  def set_title
    @page_title = 'Cofetăria Irina ・ Laborator propriu ・ str. Mioriței, nr. 10, Bacău'
    @seo_keywords = 'Bacau, Irina, cofetaria, cofetarie, cofetarii, prajitura, prajituri, tort, onomastica, botez, nunta, majorat, cozonac, cozonaci, julfa, pasca, colac, colaci, boema, africana, romania'
  end
end