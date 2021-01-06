desc "Run RuboCop"
task lint: :environment do
  sh "bundle exec rubocop"
  sh "yarn run lint"
end
