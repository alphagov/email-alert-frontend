require_relative '../../lib/govuk_content_schema_examples'

module ContentSchemaHelper
  include GovukContentSchemaExamples
end

World(ContentSchemaHelper)
