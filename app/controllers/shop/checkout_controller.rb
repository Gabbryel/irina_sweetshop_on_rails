module Shop
  class CheckoutController < BaseController
    def create
      if @cart.items.blank?
        respond_with_checkout_error('Coșul este gol.')
        return
      end

      unless cart_items_available_online?
        respond_with_checkout_error('Coșul conține produse indisponibile pentru comandă online.')
        return
      end

      form_snapshot = nil
      data = checkout_params

      raw_email = data[:email].to_s.strip
      no_email_flag = data[:no_email].to_s == '1'
      full_name = data[:full_name].to_s.strip
      phone = data[:phone].to_s.strip
      address = data[:delivery_address].to_s.strip
      notes = data[:notes].to_s.strip
      pickup_password = data[:pickup_password].to_s.strip
      method_of_delivery = (data[:method_of_delivery].presence || Cart::DELIVERY_METHODS.first).to_s
      county_raw = data[:county].to_s.strip
      raw_delivery_date = data[:delivery_date].to_s.strip

      delivery_date = parse_delivery_date(raw_delivery_date)

      if @cart.requires_pickup_only?
        method_of_delivery = 'pickup'
      end
      delivery_window = @cart.delivery_window
      # If the user checked the 'no email' checkbox, use the default placeholder
      email = if no_email_flag
                'no-mail@irinasweet.ro'
              else
                raw_email.presence || current_user&.email
              end

      form_snapshot = build_form_snapshot(
        raw_email: raw_email,
        fallback_email: email,
        full_name: full_name,
        phone: phone,
        address: address,
        notes: notes,
        county: county_raw,
        method_of_delivery: method_of_delivery,
        delivery_date: delivery_date,
        raw_delivery_date: raw_delivery_date,
        pickup_password: pickup_password
      )

      persist_cart_draft(form_snapshot, delivery_date, raw_delivery_date)

      if email.blank? && !no_email_flag
        respond_with_checkout_error('Adresa de email este necesară pentru confirmarea comenzii.', snapshot: form_snapshot)
        return
      end

      unless Cart::DELIVERY_METHODS.include?(method_of_delivery)
        respond_with_checkout_error('Te rugăm să alegi metoda de livrare.', snapshot: form_snapshot)
        return
      end

      county = county_raw.presence
      notes_value = notes.presence
      notes_with_pickup_password = [notes_value, ("Parolă ridicare: #{pickup_password}" if pickup_password.present?)].compact.join("\n")

      if delivery_date.nil?
        respond_with_checkout_error('Selectează o dată de livrare disponibilă.', snapshot: form_snapshot)
        return
      end

      if delivery_window.before_min?(delivery_date)
        respond_with_checkout_error("Data minimă pentru livrare este #{I18n.l(delivery_window.min_date)}.", snapshot: form_snapshot)
        return
      end

      if delivery_window.after_max?(delivery_date)
        respond_with_checkout_error("Data selectată depășește intervalul disponibil de #{delivery_window.max_window_days} zile.", snapshot: form_snapshot)
        return
      end

      if delivery_window.blocked?(delivery_date)
        respond_with_checkout_error('Data selectată nu este disponibilă pentru livrare. Te rugăm să alegi o altă zi.', snapshot: form_snapshot)
        return
      end

      unless delivery_window.include?(delivery_date)
        respond_with_checkout_error('Data selectată nu este disponibilă pentru livrare. Te rugăm să alegi o altă zi.', snapshot: form_snapshot)
        return
      end

      missing = []
      missing << 'numele complet' if full_name.blank?
      missing << 'numărul de telefon' if phone.blank?
      if method_of_delivery == 'delivery'
        missing << 'adresa de livrare' if address.blank?
        missing << 'județul' if county.blank?
      end

      if missing.any?
        respond_with_checkout_error("Te rugăm să completezi #{missing.to_sentence(two_words_connector: ' și ', last_word_connector: ' și ')} pentru a finaliza comanda.", snapshot: form_snapshot)
        return
      end

      address = nil if method_of_delivery == 'pickup'
      county = nil if method_of_delivery == 'pickup'

      @cart.update!(
        email: email,
        customer_full_name: full_name,
        customer_phone: phone,
        delivery_address: address,
        customer_notes: notes_with_pickup_password.presence,
        method_of_delivery: method_of_delivery,
        guest_no_email: no_email_flag,
        county: county,
        delivery_date: delivery_date
      )

      session = Stripe::Checkout::Session.create(
        mode: 'payment',
        payment_method_types: ['card'],
        customer_email: email,
        line_items: stripe_line_items,
        success_url: shop_checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: shop_checkout_cancel_url,
        metadata: {
          cart_id: @cart.id,
          user_id: current_user&.id,
          guest_token: @cart.guest_token
        }.compact
      )

      @cart.update!(email: email)
      @cart.register_checkout_session!(session_id: session.id, payment_intent: session.payment_intent)

      respond_to do |format|
        format.json do
          render json: {
            id: session.id,
            public_key: ENV['STRIPE_PUBLISHABLE_KEY'],
            url: session.url,
            cart: cart_payload(@cart)
          }, status: :ok
        end

        format.html do
          redirect_to session.url, allow_other_host: true
        end
      end
    rescue Stripe::StripeError => e
      respond_with_checkout_error(e.message, snapshot: form_snapshot)
    rescue ActiveRecord::RecordInvalid => e
      respond_with_checkout_error(e.record.errors.full_messages.to_sentence, snapshot: form_snapshot)
    end

    def success
      session_id = params[:session_id]
      if session_id.blank?
        redirect_to shop_cart_path, alert: 'Sesiunea de plată nu a fost găsită.'
        return
      end

      cart = Cart.find_by(stripe_checkout_session_id: session_id)
      if cart.blank?
        redirect_to shop_cart_path, alert: 'Coșul nu a putut fi identificat.'
        return
      end

      begin
        stripe_session = Stripe::Checkout::Session.retrieve(session_id)
      rescue Stripe::StripeError
        redirect_to shop_cart_path, alert: 'Plata nu a putut fi verificată. Te rugăm să încerci din nou.'
        return
      end

      unless stripe_session.payment_status == 'paid'
          cart.update(status: Cart::STATUSES[:no_status]) if cart.status != Cart::STATUSES[:delivered]
        redirect_to shop_cart_path, alert: 'Plata nu a fost finalizată. Te-am redirecționat înapoi la coș.'
        return
      end

        cart.update!(status: Cart::STATUSES[:delivered])
      # If the order was placed by a guest without email, expose a printable confirmation for the customer
      guest_flow = cart.guest_no_email?
      send_completion_emails(cart)
      reset_cart_session!
      new_cart = start_new_cart!

      respond_to do |format|
        if guest_flow
          format.html { redirect_to shop_guest_confirmation_path(cart.id, cart.guest_token) }
          format.json { render json: { guest_confirmation_url: shop_guest_confirmation_url(cart.id, cart.guest_token), status: cart.status }, status: :ok }
        else
          format.html { redirect_to shop_cart_path, notice: 'Plata a fost procesată cu succes!' }
          format.json { render json: { cart: cart_payload(new_cart), status: cart.status }, status: :ok }
        end
      end
    end

    def cancel
      @cart.update(status: Cart::STATUSES[:no_status]) if @cart.status != Cart::STATUSES[:completed]

      respond_to do |format|
        format.html { redirect_to shop_cart_path, alert: 'Plata a fost anulată. Puteți încerca din nou.' }
        format.json { render json: { cart: cart_payload(@cart), status: @cart.status }, status: :ok }
      end
    end

    def guest_confirmation
      id = params[:id]
      token = params[:token]
      @cart = Cart.find_by(id: id, guest_token: token)
      if @cart.blank?
        redirect_to root_path, alert: 'Confirmarea nu a putut fi găsită.'
        return
      end

      # Render a simplified printable confirmation
      render 'guest_confirmation', layout: 'application'
    end

    private

    def checkout_params
      params.fetch(:checkout, {}).permit(:email, :full_name, :phone, :delivery_address, :notes, :county, :delivery_date, :method_of_delivery, :no_email, :pickup_password)
    end

    def stripe_line_items
      currency = Money.default_currency&.iso_code&.downcase || 'ron'

      @cart.items.map do |item|
        {
          price_data: {
            currency: currency,
            unit_amount: item.total_cents,
            product_data: {
              name: item.name,
              metadata: {
                cart_item_id: item.id,
                recipe_id: item.recipe_id
              }.compact
            }
          },
          quantity: 1
        }
      end
    end

    def reset_cart_session!
      session.delete(:cart_id)
      session.delete(:cart_token)
      session.delete(:cart_last_seen_at)
      @current_cart = nil
    end

    def start_new_cart!
      cart = if current_user.present?
               Cart.create!(user: current_user)
             else
               Cart.create!
             end

      session[:cart_id] = cart.id
      session[:cart_token] = cart.guest_token if cart.guest_token.present?
      session[:cart_last_seen_at] = Time.current.iso8601
      @current_cart = cart
    end

    def send_completion_emails(order)
      OrderMailer.with(order: order).admin_notification.deliver_later
      # Do not send a customer confirmation email when the order used the guest no-email placeholder
      if !order.guest_no_email && order.contact_email.present?
        OrderMailer.with(order: order).customer_confirmation.deliver_later
      end
    rescue StandardError => e
      Rails.logger.error("OrderMailer failed for cart ##{order.id}: #{e.message}")
    end

    def cart_items_available_online?
      @cart.items.includes(:recipe).all? do |item|
        recipe = item.recipe
        recipe.present? && recipe.supports_online_ordering?
      end
    end

    def parse_delivery_date(value)
      return if value.blank?

      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def respond_with_checkout_error(message, snapshot: nil)
      respond_to do |format|
        format.json do
          response = { error: message, cart: cart_payload(@cart) }
          response[:form] = snapshot if snapshot.present?
          render json: response, status: :unprocessable_entity
        end

        format.html do
          flash[:checkout_form_data] = snapshot if snapshot.present?
          redirect_to shop_cart_path, alert: message
        end
      end
    end

    def build_form_snapshot(raw_email:, fallback_email:, full_name:, phone:, address:, notes:, county:, method_of_delivery:, delivery_date:, raw_delivery_date:, pickup_password: nil)
      {
        email: raw_email.presence || fallback_email.to_s,
        full_name: full_name,
        phone: phone,
        delivery_address: address,
        notes: notes,
        pickup_password: pickup_password,
        county: county,
        method_of_delivery: method_of_delivery,
        delivery_date: if delivery_date.present?
                         delivery_date.iso8601
                       elsif raw_delivery_date.blank?
                         ""
                       else
                         nil
                       end
      }
    end

    def persist_cart_draft(snapshot, delivery_date, raw_delivery_date)
      return if snapshot.blank?

      email_value = snapshot[:email].presence
      full_name_value = snapshot[:full_name].presence
      phone_value = snapshot[:phone].presence
      notes_value = snapshot[:notes].presence
      method_value = snapshot[:method_of_delivery].presence
      county_value = snapshot[:county].presence
      address_value = snapshot[:delivery_address].presence

      method_to_assign = Cart::DELIVERY_METHODS.include?(method_value) ? method_value : nil

      @cart.assign_attributes(
        email: email_value,
        customer_full_name: full_name_value,
        customer_phone: phone_value,
        customer_notes: notes_value,
        method_of_delivery: method_to_assign
      )

      if method_to_assign == 'delivery'
        @cart.delivery_address = address_value
        @cart.county = county_value
      elsif method_to_assign.present?
        @cart.delivery_address = nil
        @cart.county = nil
      end

      if delivery_date.present?
        @cart.delivery_date = delivery_date
      elsif raw_delivery_date.blank?
        @cart.delivery_date = nil
      end

      @cart.save(validate: false) if @cart.changed?
    end
  end
end
