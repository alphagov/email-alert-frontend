require 'slimmer/test'
require 'slimmer/test_helpers/govuk_components'

include Slimmer::TestHelpers::GovukComponents # rubocop:disable Style/MixinUsage

Before do
  stub_shared_component_locales
end
