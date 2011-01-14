require "rake/testtask"

test = namespace :test do
  Rake::TestTask.new(:functional) do |t|
    t.libs << "test"
    t.test_files = FileList["test/functional/*_test.rb"]
  end
  
  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.test_files = FileList["test/integration/*_test.rb"]
  end
  
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test"
    t.test_files = FileList["test/unit/*_test.rb"]
  end
end

task :default => [test[:integration], test[:unit]]
