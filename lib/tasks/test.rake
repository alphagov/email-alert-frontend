desc "Run all tests"
task test: [:spec, "jasmine:ci"]
