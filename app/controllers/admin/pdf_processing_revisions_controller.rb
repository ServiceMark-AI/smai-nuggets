class Admin::PdfProcessingRevisionsController < Admin::BaseController
  def index
    @revisions = PdfProcessingRevision.includes(:model).order(revision_number: :desc)
    @current = PdfProcessingRevision.is_current
  end

  def new
    @revision = PdfProcessingRevision.new
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
