module ReviewTargetHelper
  def target
    if @recipe
      @recipe
    elsif @cakemodel
      @cakemodel
    end
  end
end