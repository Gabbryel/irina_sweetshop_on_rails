module CakemodelShowHelper
  def recipe_count(cm)
    cm.model_components.count
  end

  def components(cm)
    cm.model_components
  end

  def total_weight(cm)
    components(cm) ? components(cm).map { |el| el.weight }.sum : '0'
  end

  def recipes_price(cm)
    components(cm).count > 0 ? components(cm).map { |el| el.recipe.price * el.weight}.sum : '0'
  end

  def design_price(cm)
    (cm.design.price_cents/100) * total_weight(cm)
  end

  def total_price(cm)
    return cm.final_price.to_f if cm.respond_to?(:final_price) && cm.final_price.present?

    recipes_price(cm).to_f + design_price(cm)
  end
end
