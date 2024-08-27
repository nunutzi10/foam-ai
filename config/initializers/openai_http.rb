# frozen_string_literal: true

# 10/18/2023 as per a bug in OpenAI's Ruby SDK, this patch is required
#   to avoid packet losses on streaming completions
# Description:
# When streaming data, the [to_json_stream] method in the OpenAI::HTTP
#  module may fail to correctly parse incoming JSON chunks if they
#  are split across multiple data packets.
#  This results in JSON parsing errors and incomplete or missing data in
#  the application.
# URL: https://github.com/alexrudall/ruby-openai/issues/335
# TODO: This method should be removed once the bug is fixed in the SDK.

# [OpenAi] module
module OpenAI
  # [HTTP] module
  module HTTP
    def to_json_stream(user_proc:)
      proc do |chunk, _|
        @buffer ||= ''
        @buffer += chunk
        while (match = @buffer.match(/(?:data|error): (\{.*\})/i))
          data = match[1]
          # Remove the processed data from the buffer
          @buffer = @buffer[match.end(0)..]
          begin
            user_proc.call(JSON.parse(data))
          rescue JSON::ParserError => e
            Rails.logger.error { "JSON parsing error: #{e.message}" }
          end
        end
      end
    end
  end
end
