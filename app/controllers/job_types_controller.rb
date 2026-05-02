class JobTypesController < ApplicationController
  before_action :require_tenant
  before_action :load_job_type, only: [:show, :edit, :update, :destroy]

  def index
    @job_types = scope.order(:name)
  end

  def show
  end

  def new
    @job_type = scope.build
  end

  def create
    @job_type = scope.build(job_type_params)
    if @job_type.save
      redirect_to @job_type, notice: "Job type created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @job_type.update(job_type_params)
      redirect_to @job_type, notice: "Job type updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @job_type.destroy
    redirect_to job_types_path, notice: "Job type removed."
  end

  private

  def scope
    @tenant.job_types
  end

  def load_job_type
    @job_type = scope.find(params[:id])
  end

  def job_type_params
    params.require(:job_type).permit(:name, :type_code, :description)
  end

  def require_tenant
    @tenant = current_user.tenant
    unless @tenant
      redirect_to root_path, alert: "You're not assigned to a tenant yet." and return
    end
  end
end
