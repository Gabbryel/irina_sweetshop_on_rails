class CategoriesController < ApplicationController
  def new
  end

  def create
  end

  def index
    @categories = policy_scope(Category)
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
