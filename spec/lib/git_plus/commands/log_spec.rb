# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commands::Log do
  subject(:log) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  describe "#call" do
    it "answers standard output, standard error, and status without arguments" do
      git_repo_dir.change_dir do
        expect(log.call).to match(
          array_including(/Added documentation/, "", kind_of(Process::Status))
        )
      end
    end

    it "answers standard output, standard error, and status with arguments" do
      git_repo_dir.change_dir do
        expect(log.call("-1")).to match(
          array_including(/Added documentation/, "", kind_of(Process::Status))
        )
      end
    end
  end
end
