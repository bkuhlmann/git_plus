# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commands::Branch do
  subject(:branch) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  describe "#call" do
    it "answers standard output, standard error, and status without arguments" do
      git_repo_dir.change_dir do
        expect(branch.call).to match(
          array_including("* master\n", "", kind_of(Process::Status))
        )
      end
    end

    it "answers standard output, standard error, and status with arguments" do
      git_repo_dir.change_dir do
        expect(branch.call("--list")).to match(
          array_including("* master\n", "", kind_of(Process::Status))
        )
      end
    end
  end

  describe "#name" do
    it "answers main branch name" do
      git_repo_dir.change_dir do
        expect(branch.name).to eq("master")
      end
    end

    it "answers feature branch name" do
      git_repo_dir.change_dir do
        `git switch --create example --track`
        expect(branch.name).to eq("example")
      end
    end
  end
end
