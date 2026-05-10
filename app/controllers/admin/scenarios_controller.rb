class Admin::ScenariosController < Admin::BaseController
  before_action :load_job_type, only: [:new, :create]
  before_action :load_scenario, only: [:show, :edit, :update, :destroy]

  def new
    @scenario = @job_type.scenarios.build
  end

  def create
    @scenario = @job_type.scenarios.build(scenario_params)
    if @scenario.save
      redirect_to admin_scenario_path(@scenario), notice: "Scenario created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
  end

  def edit
  end

  def update
    if @scenario.update(scenario_params)
      redirect_to admin_scenario_path(@scenario), notice: "Scenario updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    job_type = @scenario.job_type
    @scenario.destroy
    redirect_to admin_job_type_path(job_type), notice: "Scenario removed."
  end

  private

  def load_job_type
    @job_type = JobType.find(params[:job_type_id])
  end

  def load_scenario
    @scenario = Scenario.find(params[:id])
    @job_type = @scenario.job_type
  end

  def scenario_params
    params.require(:scenario).permit(:code, :short_name, :description, :campaign_id)
  end
end
