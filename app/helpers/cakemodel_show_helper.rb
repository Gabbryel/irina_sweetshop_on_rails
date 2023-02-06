module CakemodelShowHelper
  def recipe_count(cm)
    cm.model_components.count
  end
  def recipe_text(cm)
    count = recipe_count(cm)
    count == 0 ? 'adaugă componente' : count == 1 ? 'rețetei' : count > 1 ? 'rețetelor' : nil
  end

  def components(cm)
    cm.model_components
  end

  def total_weight(cm)
    components(cm).map { |el| el.weight }.sum
  end

  def one_comp(cm)
    components(cm)[0]
  end

  def recipes_price(cm)
    components(cm).map { |el| el.recipe_price * el.weight}.sum
  end

  def design_price(cm)
    (cm.design.price_cents/100) * total_weight(cm)
  end

  def total_price(cm)
    recipes_price(cm) + design_price(cm)
  end
end