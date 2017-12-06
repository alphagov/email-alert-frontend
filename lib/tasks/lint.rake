desc "Run govuk-lint with similar params to CI"
task lint: :environment do
  sh "govuk-lint-ruby --format clang Gemfile app config features lib spec"
end
