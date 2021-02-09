# frozen_string_literal: true

module GitPlus
  module Refinements
    # Provides commit specific string enhancements.
    module Strings
      refine String do
        def pluralize count:, suffix: "s"
          return "#{count} #{self}" if count == 1

          "#{count} #{self}#{suffix}"
        end

        def fixup? = match?(/\Afixup!\s/)

        def squash? = match?(/\Asquash!\s/)
      end
    end
  end
end
