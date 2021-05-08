# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commands::RevParse do
  subject(:rev_parse) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  describe "#call" do
    it "answers result when valid" do
      stdout, _stderr, _status = rev_parse.call "--git-dir"
      expect(stdout).to eq(".git\n")
    end

    it "answers error when invalid" do
      _stdout, stderr, _status = rev_parse.call "unknown"
      expect(stderr).to match(/fatal.+ambiguous argument/)
    end
  end

  describe "#directory?" do
    it "answers true when repository exists" do
      git_repo_dir.change_dir { expect(rev_parse.directory?).to eq(true) }
    end

    it "answers false when repository doesn't exist" do
      temp_dir.change_dir { expect(rev_parse.directory?).to eq(false) }
    end
  end
end
