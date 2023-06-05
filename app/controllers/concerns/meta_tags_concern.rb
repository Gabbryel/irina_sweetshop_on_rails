module MetaTagsConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_title
  end

  def set_title
    @page_title = 'Cofetărie - Laborator Irina ・ Bacău, bd. Unirii, nr. 2'
    @seo_keywords = 'Bacau, Irina, cofetaria, cofetarie, cofetarii, prajitura, prajituri, tort, onomastica, botez, nunta, majorat, cozonac, cozonaci, julfa, pasca, colac, colaci, boema, africana, romania, mirabel, pavlova, dulcineea, dulcinella'
  end
end
