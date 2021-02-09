# frozen_string_literal: true

module GitPlus
  # Represents all details of a commit.
  Commit = Struct.new(
    :author_date_relative,
    :author_email,
    :author_name,
    :body,
    :body_lines,
    :body_paragraphs,
    :message,
    :sha,
    :subject,
    :trailers,
    :trailers_index,
    keyword_init: true
  ) do
    using Refinements::Strings

    def fixup? = subject.fixup?

    def squash? = subject.squash?
  end
end
