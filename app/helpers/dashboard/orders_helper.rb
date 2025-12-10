module Dashboard
  module OrdersHelper
    ORDERED_STATUSES = %w[no_status seen in_production ready delivered canceled refunded].freeze

    def order_status_badge(order)
      content_tag(:span, order.status_label, class: "badge bg-#{order.status_badge_variant}")
    end

    def order_status_options
      Cart::STATUSES.values.map do |value|
        [Cart::STATUS_LABELS[value] || value.titleize, value]
      end
    end

    def format_order_total(order)
      order.total_money.format
    end

    def format_order_quantity(order)
      quantity = order.total_quantity
      quantity == quantity.to_i ? quantity.to_i : number_with_precision(quantity, precision: 2)
    end

    def render_contact_detail(label, value)
      content_tag(:p, class: 'mb-1') do
        concat content_tag(:span, "#{label}:", class: 'text-muted me-1')
        concat(value.presence || '-')
      end
    end

    def human_delivery_method(order)
      case order.method_of_delivery
      when 'delivery'
        'Livrare'
      when 'pickup'
        'Ridicare personală'
      else
        '-'
      end
    end

    def order_status_button_class(order, status_value)
      base_classes = %w[btn btn-sm px-2 py-0]

      current_index = ORDERED_STATUSES.index(order.status.to_s) || -1
      target_index = ORDERED_STATUSES.index(status_value.to_s)

      color_class = if target_index.nil?
                      'btn-outline-secondary'
                    elsif target_index < current_index
                      'btn-outline-success' # passed
                    elsif target_index > current_index
                      'btn-outline-danger'  # future
                    else
                      'btn-outline-warning' # current (should be skipped, defensive)
                    end

      (base_classes + [color_class]).join(' ')
    end
  end
end
