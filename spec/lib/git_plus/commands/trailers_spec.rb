# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commands::Trailers do
  subject(:trailers) { described_class.new }

  let(:path) { Bundler.root.join "spec/support/fixtures/commit-valid.txt" }

  describe "#call" do
    it "answers standard output, standard error, and status without arguments" do
      expect(trailers.call).to match(
        array_including("\n", "", kind_of(Process::Status))
      )
    end

    it "answers standard output, standard error, and status with file path" do
      expect(trailers.call("--only-trailers", path.to_s)).to match(
        array_including("One: 1\nTwo: 2\n", "", kind_of(Process::Status))
      )
    end

    it "answers standard output, standard error, and status with file contents" do
      expect(trailers.call("--only-trailers", stdin_data: path.read)).to match(
        array_including("One: 1\nTwo: 2\n", "", kind_of(Process::Status))
      )
    end

    it "answers standard output, standard error, and status when file ends in comments" do
      path = Bundler.root.join "spec/support/fixtures/commit-scissors.txt"

      expect(trailers.call("--only-trailers", path.to_s)).to match(
        array_including("", "", kind_of(Process::Status))
      )
    end

    it "answers standard output, standard error, and status when file has no trailers" do
      path = Bundler.root.join "spec/support/fixtures/commit-invalid.txt"

      expect(trailers.call("--only-trailers", path.to_s)).to match(
        array_including("", "", kind_of(Process::Status))
      )
    end
  end

  describe "#list" do
    it "answers array with file path" do
      expect(trailers.list(path.to_s)).to contain_exactly("One: 1", "Two: 2")
    end

    it "answers array with file contents" do
      expect(trailers.list(stdin_data: path.read)).to contain_exactly("One: 1", "Two: 2")
    end

    it "answers empty array without file path or contents" do
      expect(trailers.list).to eq([])
    end
  end
end
