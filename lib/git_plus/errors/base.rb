# frozen_string_literal: true

module GitPlus
  module Errors
    # Root class of all gem related errors.
    class Base < StandardError
      def initialize message = "Invalid #{Identity::LABEL} action."
        super message
      end
    end
  end
end
