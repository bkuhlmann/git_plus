# frozen_string_literal: true

RSpec.shared_context "with Git commit" do
  let :git_commit do
    GitPlus::Commit[
      author_date_relative: "1 day ago",
      author_email: "test@example.com",
      author_name: "Test User",
      body: "",
      message: "",
      sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
      subject: "Added documentation",
      trailers: ""
    ]
  end
end
