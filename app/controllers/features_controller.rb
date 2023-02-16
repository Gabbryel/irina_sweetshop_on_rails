class FeaturesController < ApplicationController
  def new
    @feature = authorize Feature.new()
  end

  def create
    @feature = authorize Feature.create(feature_params)
    if @feature.save!
      redirect_to dashboard_features_path
    end
  end

  def edit
    @feature = authorize Feature.find(params[:id])
  end

  def update
    @feature = authorize Feature.find(params[:id])

    if @feature.update(feature_params)
      redirect_to dashboard_features_path
    end
  end

  def index
    @features = policy_scope(Feature)
    @feature = Feature.new()
  end

  def show
    @feature = authorize Feature.find(params[:id])
  end

  def destroy
    @feature = authorize Feature.find(params[:id])
    if @feature.destroy
      redirect_to dashboard_features_path
    end
  end

  private

  def feature_params
    params.require(:feature).permit(:title, :photo, :content)
  end
end
