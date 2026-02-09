class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :how_to_order, :about, :valori_nutritionale, :gdpr]

  def home
    @recipes = Recipe.where(favored: true).order(position: :asc).first(9)
    @features = Feature.all.order(:id)
    @categories = Category.all.order(:id)
  end

  def recepies
  end

  def how_to_order
    @page_main_title = 'Cum comand?'
  end

  def about
    @page_main_title = 'Despre noi'
  end

  def valori_nutritionale
    @page_main_title = 'Valori nutriționale'
    @categories = Category.all.order(:name)
  end

  def gdpr
    @page_title = 'Politica de confidențialitate și cookies'
    @page_main_title = 'Protecția datelor (GDPR)'
    @seo_keywords = 'politica cookies, confidențialitate, GDPR Irina Sweet'
  end

  def admin_dashboard
    unless current_user&.admin?
      redirect_to root_path, alert: 'Nu ai acces la această secțiune.'
      return
    end

    @page_main_title = 'Dashboard administrare'

    actionable_statuses = Cart::STATUSES.values
    orders_scope = Cart.where(status: actionable_statuses)

    @orders_total = orders_scope.count
    open_statuses = [Cart::STATUSES[:no_status], Cart::STATUSES[:seen], Cart::STATUSES[:in_production], Cart::STATUSES[:ready]]
    @pending_orders_count = orders_scope.where(status: open_statuses).count
    @completed_orders_count = orders_scope.where(status: Cart::STATUSES[:delivered]).count
    @orders_this_week = orders_scope.where('created_at >= ?', 1.week.ago).count

    revenue_scope = Item.joins(:cart).where(carts: { status: Cart::STATUSES[:delivered] })
    @revenue_all_time = Money.new(revenue_scope.sum(:total_cents) || 0, Money.default_currency)
    @revenue_this_month = Money.new(
      revenue_scope.where('carts.updated_at >= ?', Time.current.beginning_of_month).sum(:total_cents) || 0,
      Money.default_currency
    )

    @new_users_this_month = User.where('created_at >= ?', Time.current.beginning_of_month).count

    @recent_orders = orders_scope.includes(:user, :items).order(created_at: :desc).limit(5)
    @pending_reviews = Review.where(approved: false).includes(:reviewable, :user).order(created_at: :desc).limit(5)

    approved_reviews_scope = Review.where(approved: true)
    @approved_reviews_count = approved_reviews_scope.count
    @average_rating = approved_reviews_scope.average(:rating)&.to_f&.round(1)

    @quick_links = [
      { title: 'Administrare comenzi', description: 'Vezi comenzi, actualizează statusul și urmărește livrările.', path: dashboard_orders_path, icon: 'fa-solid fa-clipboard-list' },
      { title: 'Hero Section', description: 'Personalizează secțiunea principală a paginii de acasă.', path: edit_dashboard_design_hero_section_path, icon: 'fa-solid fa-image' },
      { title: 'Administrează rețetele', description: 'Editează rețete și organizează meniul online.', path: dashboard_recipes_path, icon: 'fa-solid fa-utensils' },
      { title: 'Actualizează prețurile', description: 'Modifică rapid prețurile produselor listate.', path: preturi_path, icon: 'fa-solid fa-tags' },
      { title: 'Jurnal de activitate', description: 'Monitorizează toate acțiunile utilizatorilor și evenimentele de securitate.', path: dashboard_audit_logs_path, icon: 'fa-solid fa-file-shield' },
      { title: 'Analiză trafic', description: 'Vizualizează statistici despre vizitatori și comportamentul pe site.', path: dashboard_analytics_path, icon: 'fa-solid fa-chart-line' },
      { title: 'Zile livrare', description: 'Gestionează zilele disponibile pentru comenzi și livrări.', path: dashboard_delivery_dates_path, icon: 'fa-solid fa-calendar-check' },
      { title: 'Design-uri personalizate', description: 'Gestionează variantele de design pentru modele.', path: dashboard_designs_path, icon: 'fa-solid fa-cake-candles' },
      { title: 'Elemente de prezentare', description: 'Administrează secțiunea cu avantaje și beneficii.', path: dashboard_features_path, icon: 'fa-solid fa-star' },
      { title: 'Administrare utilizatori', description: 'Verifică noile conturi și rolurile de acces.', path: dashboard_path(anchor: 'users-admin'), icon: 'fa-solid fa-users' }
    ]

    @stats_cards = [
      { label: 'Total comenzi', value: @orders_total, hint_value: @completed_orders_count, hint_label: 'finalizate', icon: 'fa-solid fa-receipt' },
      { label: 'Comenzi în curs', value: @pending_orders_count, hint_value: @orders_this_week, hint_label: 'în ultimele 7 zile', icon: 'fa-solid fa-truck' },
      { label: 'Utilizatori noi', value: @new_users_this_month, hint_label: 'Conturi create în luna curentă', icon: 'fa-solid fa-user-plus' },
      { label: 'Rating mediu', value: (@average_rating ? "#{@average_rating} / 5" : '—'), hint_value: @approved_reviews_count, hint_label: 'recenzii aprobate', icon: 'fa-solid fa-face-smile' }
    ]

    @users_total = User.count
    @admins_count = User.where(admin: true).count
    @users_without_orders = User.left_outer_joins(:carts).where(carts: { id: nil }).count
    @users_with_orders_this_month = User.joins(:carts).where('carts.created_at >= ?', Time.current.beginning_of_month).distinct.count
    @recent_users = User.includes(:carts).order(created_at: :desc).limit(8)

    @user_metrics = [
      { label: 'Utilizatori totali', value: @users_total },
      { label: 'Administratori activi', value: @admins_count },
      { label: 'Comenzi în luna curentă', value: @users_with_orders_this_month },
      { label: 'Fără comenzi', value: @users_without_orders }
    ]
  end
end
