# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commands::Branch do
  subject(:branch) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  describe "#default" do
    it "answers main branch when defined" do
      git_repo_dir.change_dir do
        expect(branch.default).to eq("main")
      end
    end

    it "answers master branch when undefined" do
      git_repo_dir.change_dir do
        `git config --add init.defaultBranch ""`
        expect(branch.default).to eq("master")
      end
    end

    it "answers custom branch when defined" do
      git_repo_dir.change_dir do
        `git config --add init.defaultBranch "source"`
        expect(branch.default).to eq("source")
      end
    end
  end

  describe "#call" do
    it "answers standard output, standard error, and status without arguments" do
      git_repo_dir.change_dir do
        expect(branch.call).to match(
          array_including("* main\n", "", kind_of(Process::Status))
        )
      end
    end

    it "answers standard output, standard error, and status with arguments" do
      git_repo_dir.change_dir do
        expect(branch.call("--list")).to match(
          array_including("* main\n", "", kind_of(Process::Status))
        )
      end
    end
  end

  describe "#name" do
    it "answers default branch name" do
      git_repo_dir.change_dir do
        expect(branch.name).to eq("main")
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
