class Admin::JobTypesController < Admin::BaseController
  before_action :load_job_type, only: [:show, :edit, :update, :destroy]

  def index
    @job_types = JobType.includes(:tenant).order("tenants.name", :name)
  end

  def show
  end

  def new
    @job_type = JobType.new(tenant_id: params[:tenant_id])
  end

  def create
    @job_type = JobType.new(job_type_params)
    if @job_type.save
      redirect_to admin_job_type_path(@job_type), notice: "Job type created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @job_type.update(job_type_params)
      redirect_to admin_job_type_path(@job_type), notice: "Job type updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @job_type.destroy
    redirect_to admin_job_types_path, notice: "Job type removed."
  end

  private

  def load_job_type
    @job_type = JobType.find(params[:id])
  end

  def job_type_params
    params.require(:job_type).permit(:tenant_id, :name, :type_code, :description)
  end
end
