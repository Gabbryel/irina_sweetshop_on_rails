class DesignsController < ApplicationController
  before_action :set_design, only: %i[show edit update destroy]
  def new
    @design = authorize Design.new()
  end

  def create
    @design = authorize Design.create(design_params)
    @design.category = Category.find(params[:design][:category_id])
    if @design.save!
      redirect_to '/dashboard/designs'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @design.category = Category.find(params[:design][:category_id])
    if @design.update(design_params)
      redirect_to '/dashboard/designs'
    end
  end

  def index
    @designs = policy_scope(Design)
    @design = authorize Design.new()
  end

  def destroy
    if @design.destroy
      redirect_to '/dashboard/designs'
    end
  end

  private

  def design_params
    params.require(:design).permit(:name, :price_cents, :design_id)
  end

  def set_design
    @design = authorize Design.find(params[:id])
  end
end
