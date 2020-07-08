desc "Run RuboCop"
task lint: :environment do
  sh "bundle exec rubocop --format clang"
  sh "yarn run lint"
end
