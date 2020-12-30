# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Repository do
  subject :repository do
    described_class.new delegates: described_class::DELEGATES.merge(delegate_tag: tag)
  end

  include_context "with Git repository"

  using Refinements::Pathnames

  let(:tag) { instance_spy GitPlus::Commands::Tag }

  describe "#branch" do
    it "answers main branch" do
      git_repo_dir.change_dir do
        expect(repository.branch).to match(
          array_including("* master\n", "", kind_of(Process::Status))
        )
      end
    end
  end

  describe "#branch_name" do
    it "answers branch name" do
      git_repo_dir.change_dir do
        expect(repository.branch_name).to eq("master")
      end
    end
  end

  describe "#commits" do
    let :proof do
      hash_including(
        author_date_relative: /\A\d+ seconds?? ago\Z/,
        author_email: "test@example.com",
        author_name: "Test User",
        body: "",
        body_lines: [],
        body_paragraphs: [],
        message: "Added documentation\n",
        sha: /\A[0-9a-f]{40}\Z/,
        subject: "Added documentation",
        trailers: [],
        trailers_index: nil
      )
    end

    it "answers saved commit" do
      git_repo_dir.change_dir do
        expect(repository.commits.map(&:to_h)).to contain_exactly(proof)
      end
    end
  end

  describe "#config" do
    it "answers configuration usage" do
      git_repo_dir.change_dir do
        expect(repository.config).to match(
          array_including("", /usage: git config/, kind_of(Process::Status))
        )
      end
    end
  end

  describe "#config_get" do
    let(:key) { "user.name" }

    it "answers value" do
      git_repo_dir.change_dir do
        expect(repository.config_get(key)).to eq("Test User")
      end
    end
  end

  describe "#config_remote?" do
    it "answers false when remote repository isn't defined" do
      git_repo_dir.change_dir do
        expect(repository.config_remote?).to eq(true)
      end
    end
  end

  describe "#config_set" do
    it "sets key with value" do
      key = "user.name"
      value = "Jayne Doe"

      git_repo_dir.change_dir do
        repository.config_set key, value
        expect(repository.config_get(key)).to eq(value)
      end
    end
  end

  describe "#log" do
    it "answers commit log/history" do
      git_repo_dir.change_dir do
        expect(repository.log).to match(
          array_including(/Added documentation/, "", kind_of(Process::Status))
        )
      end
    end
  end

  describe "#rev_parse" do
    it "answers empty revision history" do
      git_repo_dir.change_dir do
        expect(repository.rev_parse).to match(
          array_including("", "", kind_of(Process::Status))
        )
      end
    end
  end

  describe "#exist?" do
    it "answers true when repository exists" do
      git_repo_dir.change_dir do
        expect(repository.exist?).to eq(true)
      end
    end
  end

  describe "#tag" do
    it "delegates to tag command" do
      repository.tag
      expect(tag).to have_received(:call)
    end
  end

  describe "#tag_exist?" do
    it "answers if tag exists" do
      repository.tag_exist? "0.1.0"
      expect(tag).to have_received(:exist?).with("0.1.0")
    end
  end

  describe "#tag_last" do
    it "answers last tag" do
      repository.tag_last
      expect(tag).to have_received(:last)
    end
  end

  describe "#tag_local?" do
    it "answers if tag is local" do
      repository.tag_local? "0.1.0"
      expect(tag).to have_received(:local?).with("0.1.0")
    end
  end

  describe "tag_push" do
    it "pushes tags" do
      repository.tag_push
      expect(tag).to have_received(:push)
    end
  end

  describe "#tag_remote?" do
    it "answers if tag is remote" do
      repository.tag_remote? "0.1.0"
      expect(tag).to have_received(:remote?).with("0.1.0")
    end
  end

  describe "#tag_sign" do
    it "creates signed tag" do
      repository.tag_sign "0.1.0", "Test."
      expect(tag).to have_received(:sign).with("0.1.0", "Test.")
    end
  end

  describe "#tagged?" do
    it "answers if tagged" do
      repository.tagged?
      expect(tag).to have_received(:tagged?)
    end
  end

  describe "#tag_unsign" do
    it "creates unsign tag" do
      repository.tag_unsign "0.1.0", "Test."
      expect(tag).to have_received(:unsign).with("0.1.0", "Test.")
    end
  end

  describe "#trailers" do
    it "answers commit trailers" do
      path = Bundler.root.join "spec/support/fixtures/commit-valid.txt"
      stdout, _stderr, _status = repository.trailers "--only-trailers", path.to_s

      expect(stdout).to eq("One: 1\nTwo: 2\n")
    end
  end

  describe "#trailers_list" do
    it "answers commit trailers array" do
      path = Bundler.root.join "spec/support/fixtures/commit-valid.txt"
      expect(repository.trailers_list(path.to_s)).to contain_exactly("One: 1", "Two: 2")
    end
  end

  describe "#unsaved" do
    let(:path) { temp_dir.join("test.txt").write "Added documentation" }

    let :proof do
      {
        author_date_relative: "0 seconds ago",
        author_email: "test@example.com",
        author_name: "Test User",
        body: "",
        body_lines: [],
        body_paragraphs: [],
        message: "Added documentation",
        sha: /\A[0-9a-f]{40}\Z/,
        subject: "Added documentation",
        trailers: [],
        trailers_index: nil
      }
    end

    it "answers unsaved commit" do
      git_repo_dir.change_dir do
        expect(repository.unsaved(path).to_h).to match(proof)
      end
    end
  end
end
