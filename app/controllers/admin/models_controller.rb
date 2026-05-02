class Admin::ModelsController < Admin::BaseController
  def index
    @models = Model.order(:provider, :name)
  end
end
