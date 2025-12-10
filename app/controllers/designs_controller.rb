class DesignsController < ApplicationController
  before_action :set_design, only: %i[edit update destroy]
  before_action :load_categories, only: %i[index create edit update]

  def index
    authorize Design

    @designs = policy_scope(Design).includes(:category).order(created_at: :desc)
    @design = authorize Design.new

    prepare_dashboard_stats(@designs)
  end

  def new
    authorize Design
    redirect_to dashboard_designs_path
  end

  def create
    @design = authorize Design.new(design_params)

    if @design.save
      redirect_to dashboard_designs_path, notice: 'Designul a fost creat.'
    else
      @designs = policy_scope(Design).includes(:category).order(created_at: :desc)
      prepare_dashboard_stats(@designs)
      flash.now[:alert] = @design.errors.full_messages.to_sentence.presence || 'Nu am putut salva designul.'
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @design.update(design_params)
      redirect_to dashboard_designs_path, notice: 'Designul a fost actualizat.'
    else
      flash.now[:alert] = @design.errors.full_messages.to_sentence.presence || 'Nu am putut actualiza designul.'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @design.destroy
      redirect_to dashboard_designs_path, notice: 'Designul a fost sters.'
    else
      redirect_to dashboard_designs_path, alert: 'Nu am putut sterge designul.'
    end
  end

  private

  def design_params
    params.require(:design).permit(:name, :price_cents, :category_id)
  end

  def set_design
    @design = authorize Design.find(params[:id])
  end

  def load_categories
    @categories = Category.order(:name)
  end

  def money_from_cents(cents)
    Money.new(cents || 0, Money.default_currency)
  end

  def prepare_dashboard_stats(designs)
    designs_count = designs.size
    categorized_designs = designs.map(&:category_id).compact.uniq.size
    average_price_cents = designs.average(:price_cents)&.to_f&.round
    last_update = designs.maximum(:updated_at)

    @stats_cards = [
      { label: 'Designuri active', value: designs_count, hint: 'Designuri listate', icon: 'fa-solid fa-palette' },
      { label: 'Categorii acoperite', value: "#{categorized_designs}/#{@categories.size}", hint: 'Categorii cu cel putin un design', icon: 'fa-solid fa-layer-group' },
      { label: 'Pret mediu', value: money_from_cents(average_price_cents).then { |m| m.cents.positive? ? m.format : 'N/A' }, hint: 'Calculat din preturile afisate', icon: 'fa-solid fa-coins' },
      { label: 'Ultima actualizare', value: last_update ? I18n.l(last_update, format: :short) : 'N/A', hint: last_update ? "Actualizat #{view_context.time_ago_in_words(last_update)} in urma" : 'Nu exista actualizari recente', icon: 'fa-solid fa-clock' }
    ]
  end
end
