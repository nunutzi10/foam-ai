# frozen_string_literal: true

# Jsonable concern
# Define common json responses and http status
#
module Jsonable
  extend ActiveSupport::Concern

  protected

  # serialized the given ruby +Object+ to a JSON response for an optional
  # HTTP +status+ attribute.
  # When this method is called, response is terminated.
  # @return nil
  def json_response(object, status = :ok, args = {})
    args = {} if args.nil? || args.is_a?(StandardError)
    args[:status] = status
    args[:json] = object
    render args
  end
end
