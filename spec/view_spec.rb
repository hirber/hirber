require "hirber"
require "spec_helper"

RSpec.describe "Hirb::View" do
  it "page_output pages when view is enabled" do
    reset_config

    Hirb.enable

    allow(Hirb::View.pager).to receive_messages(activated_by?: true)
    expect(Hirb::View.pager).to receive(:page)
    expect(Hirb::View.page_output("blah")).to be(true)

    Hirb.disable
  end

  it "page_output doesn't page when view is disabled" do
    Hirb.enable
    Hirb.disable

    allow(Hirb::View.pager).to receive_messages(activated_by?: true)

    expect(Hirb::View.pager).not_to receive(:page)
    expect(Hirb::View.page_output("blah")).to be(false)
  end

  it "view_output catches unexpected errors and prints them" do
    reset_config

    Hirb.enable

    allow(::Hirb::View).to receive(:render_output).and_raise("error")

    expect(capture_stderr { Hirb::View.view_output([1,2,3]) })
      .to match(/Hirb Error: error/)

    Hirb.disable
  end

  describe "enable" do
    before { reset_config }

    after { Hirb.disable }

    it "redefines irb output_value" do
      expect(Hirb::View).to receive(:render_output)

      Hirb.enable

      context_stub = double(last_value: "")

      ::IRB::Irb.new(context_stub).output_value
    end

    it "is enabled?" do
      reset_config

      Hirb.enable

      expect(Hirb::View).to be_enabled
    end

    def output_class_config(klass)
      { :output=>{klass=>{:class=>:auto_table}} }
    end

    it "sets formatter config" do
      class_hash = {"Something::Base"=>{:class=>"BlahBlah"}}

      Hirb.enable :output => class_hash

      expect(Hirb::View.formatter_config["Something::Base"])
        .to eq class_hash["Something::Base"]
    end

    it "when called multiple times merges configs" do
      Hirb.config = nil
      # default config + config_file

      allow(Hirb)
        .to receive_messages(
          read_config_file: output_class_config("Regexp"),
        )

      Hirb.enable output_class_config("String")

      # add config file and explicit config
      [{:config_file=>"ok"}, output_class_config("Struct")].each do |config|
        expect(Hirb)
          .to receive(:read_config_file)
          .and_return(
            output_class_config('ActiveRecord::Base'),
            output_class_config('Array'),
          )

        Hirb.enable config
      end

      expect(Hirb.config_files.include?("ok")).to eq(true)

      output_keys = %w{ActiveRecord::Base Array Regexp String Struct}

      expect(Hirb::View.config[:output].keys.sort).to eq output_keys
    end

    xit "when called multiple times without config doesn't affect config" do
      # FIXME: 2021-02-14 - This flapping, spec is order dependant

      Hirb.enable

      old_config = Hirb::View.config

      expect(Hirb).not_to receive(:read_config_file)
      expect(Hirb::View).not_to receive(:load_config)

      # Hirb.expects(:read_config_file).never
      # Hirb::View.expects(:load_config).never

      Hirb.enable

      expect(Hirb::View.config).to eq old_config
    end

    xit "works without irb" do
      # FIXME: 2021-02-14 - This flapping, spec is order dependant

      allow(Object)
        .to receive(:const_defined?)
        .with(:IRB)
        .and_return(false)

      Hirb.enable

      expect(Hirb::View.formatter.config.size).to be > 1
    end

    it "with config_file option adds to config_file" do
      Hirb.enable :config_file => "test_file"

      expect(Hirb.config_files.include?("test_file")).to be(true)
    end

    it "with ignore_errors enable option" do
      Hirb.enable :ignore_errors => true

      expect(Hirb::View)
        .to receive(:render_output)
        .and_raise(Exception, "Ex mesg")
        .twice

      capture_stderr do
        expect(Hirb::View.view_output("")).to eq(false)
      end

      expect(capture_stderr { Hirb::View.view_output("") })
        .to match(/Error: Ex mesg/)
    end
  end

  describe "resize" do
    def pager; Hirb::View.pager; end

    before do
      Hirb::View.pager = nil
      reset_config
      Hirb.enable
    end

    after { Hirb.disable }

    it "changes width and height with stty" do
      if RUBY_PLATFORM[/java/]
        allow(Hirb::Util)
          .to receive(:command_exists?)
          .with("tput")
          .and_returns(false)
      end

      allow(STDIN)
        .to receive(:tty?)
        .and_return(true)

      allow(Hirb::Util)
        .to receive(:command_exists?)
        .with("stty")
        .and_return(true)

      ENV["COLUMNS"] = ENV["LINES"] = nil # bypasses env usage

      capture_stderr { Hirb::View.resize }

      expect(pager.width).not_to eq 10
      expect(pager.height).not_to eq 10

      reset_terminal_size
    end

    it "changes width and height with ENV" do
      ENV["COLUMNS"] = ENV["LINES"] = "10" # simulates resizing

      Hirb::View.resize

      expect(pager.width).to eq 10
      expect(pager.height).to eq 10
    end

    it "with no environment or stty still has valid width and height" do
      Hirb::View.config[:width] = Hirb::View.config[:height] = nil

      unless RUBY_PLATFORM[/java/]
        allow(Hirb::Util)
          .to receive(:command_exists?)
          .with("stty")
          .and_return(false)
      end

      ENV["COLUMNS"] = ENV["LINES"] = nil

      Hirb::View.resize

      expect(pager.width.is_a?(Integer)).to eq(true)
      expect(pager.height.is_a?(Integer)).to eq(true)

      reset_terminal_size
    end
  end

  it "disable points output_value back to original output_value" do
    expect(Hirb::View).not_to receive(:render_output)

    Hirb.enable
    Hirb.disable

    context_stub = double(:last_value=>"")

    ::IRB::Irb.new(context_stub).output_value
  end

  it "disable works without irb defined" do
    # Object.stubs(:const_defined?).with(:IRB).returns(false)
    allow(Object).to receive(:const_defined?).with(:IRB).and_return(false)

    Hirb.enable
    Hirb.disable

    expect(Hirb::View.enabled?).to eq(false)
  end

  it "capture_and_render" do
    string = "no waaaay"

    # Hirb::View.render_method.expects(:call).with(string)
    allow(Hirb::View.render_method).to receive(:call).with(string)
    Hirb::View.capture_and_render { print string }
  end

  xit "state is toggled by toggle_pager" do
    # FIXME: 2021-02-14 - This causes other specs to fail

    previous_state = Hirb::View.config[:pager]

    Hirb::View.toggle_pager

    expect(Hirb::View.config[:pager]).not_to eq(previous_state)
  end

  xit "state is toggled by toggle_formatter" do
    # FIXME: 2021-02-14 - This causes other specs to fail

    Hirb.enable

    previous_state = Hirb::View.config[:formatter]

    Hirb::View.toggle_formatter

    expect(Hirb::View.config[:formatter]).not_to eq(previous_state)
  end
end
