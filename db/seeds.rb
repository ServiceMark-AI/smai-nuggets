# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "Password1"
  u.password_confirmation = "Password1"
  u.is_admin = true
  u.is_pending = false
end

gemini_flash = Model.find_or_create_by!(model_id: "gemini-2.5-flash") do |m|
  m.name = "Gemini 2.5 Flash"
  m.provider = "gemini"
end

pdf_extraction_prompt = <<~PROMPT
  You are an expert data extraction AI. Your task is to meticulously analyze the provided document and extract
    key details into a structured JSON format.

    **Instructions:**

    1.  **Analyze the Document:** Carefully read the entire document.
    2.  **Extract Key Information:** Identify and extract the following fields.
    3.  **Format as JSON:** Return **ONLY** the raw JSON object. Absolutely DO NOT include markdown code blocks,
    backticks (```), or explanatory text.
    4.  **Handle Missing Data:** If a field cannot be found, is ambiguous, or is not applicable, the value in the
    JSON output for that key **must be `null`**. Do not invent or guess data.
    5.  **Dates:** Format all dates as `YYYY-MM-DD`.
    6.  **Amounts:** Extract all monetary values as raw JSON numbers without currency symbols or commas (e.g.,
    12345.67). Make sure they are JSON numbers, not strings.

    **Extraction Fields:**

    *   `title`: The customer's formal title (e.g., Mr., Mrs., Ms., Dr.).
    *   `firstName`, `lastName`, `email`
    *   `jobDescription`: Concise one-sentence summary
    *   `internalRef`: Job number / estimate ID
    *   `jobType`: Inferred from `{{jobTypes}}` (templated at runtime)
    *   `estimateDate`, `expirationDate` (YYYY-MM-DD)
    *   `subtotal`, `taxAmount`, `discountAmount`, `depositAmount`, `totalAmount`
    *   `isEmergency`, `estimatedDuration`, `warrantyIncluded`, `optionsProvided`, `paymentTerms`
    *   `houseNumber`, `street`, `city`, `state`, `zip`

    **JSON Output Structure:** { ...all the above keys... }
PROMPT

PdfProcessingRevision.find_or_create_by!(instructions: pdf_extraction_prompt) do |r|
  r.model = gemini_flash
end
