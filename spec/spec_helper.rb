module RSpec::Helpers
  ENV["LINES"] = ENV["COLUMNS"] = "20"

  def reset_config
    Hirb::View.instance_eval do
      @config = nil
    end
  end

  def capture_stderr(&block)
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end

  def reset_terminal_size
    ENV["LINES"] = ENV["COLUMNS"] = "20"
  end
end

module ::IRB
  class Irb
    def initialize(context)
      @context = context
    end

    def output_value; end
  end
end

RSpec.configure do |config|
  include RSpec::Helpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.bisect_runner = :shell
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 5
  config.order = :random

  Kernel.srand config.seed
end
