module CakemodelShowHelper
  def recipe_count(cm)
    cm.model_components.count
  end
  def recipe_text(cm)
    count = recipe_count(cm)
    count == 0 ? 'adaugă componente' : count == 1 ? 'rețetei' : count > 1 ? 'rețetelor' : nil
  end

  def one_comp(cm)
    cm.model_components[0]
  end

  def price_one_comp(cm)
    (one_comp(cm).recipe_price * one_comp(cm).weight) + ((cm.design.price_cents/100) * one_comp(cm).weight)
  end
end