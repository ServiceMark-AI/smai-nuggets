class Admin::PdfProcessingRevisionsController < Admin::BaseController
  def index
    @current = PdfProcessingRevision.includes(:model).is_current
    # The index page renders the current revision in full at the top,
    # so exclude it from the "Previous revisions" table to avoid showing
    # the same row twice.
    @previous_revisions = PdfProcessingRevision
      .includes(:model)
      .where.not(id: @current&.id)
      .order(revision_number: :desc)
  end

  def show
    @revision = PdfProcessingRevision.includes(:model).find(params[:id])
    @current = PdfProcessingRevision.is_current
  end

  def new
    current = PdfProcessingRevision.is_current
    @revision = PdfProcessingRevision.new(
      instructions: current&.instructions,
      model: current&.model
    )
  end

  def create
    @revision = PdfProcessingRevision.new(revision_params)
    if @revision.save
      redirect_to admin_pdf_processing_revisions_path, notice: "Revision ##{@revision.revision_number} created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def revision_params
    params.require(:pdf_processing_revision).permit(:instructions, :model_id)
  end
end
