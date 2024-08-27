# frozen_string_literal: true

# +DateFilterable+ module.
module DateFilterable
  extend ActiveSupport::Concern
  included do
    # returns an Active:Record instance of the collection filtered by
    #  +start_date+ and +end_date+ params.
    # @param [DateTime] - start_date
    # @param [DateTime] - end_date
    # @return ActiveRecord::Relation
    def self.filter_by_date(start_date, end_date, field = 'created_at')
      result = where(nil)
      if start_date.present?
        start_date = Time.zone.parse(start_date) unless start_date.is_a? Time
        result = result.where(
          "#{table_name}.#{field} >= ?", start_date.beginning_of_day
        )
      end
      if end_date.present?
        end_date = Time.zone.parse(end_date) unless end_date.is_a? Time
        result = result.where "#{table_name}.#{field} <= ?", end_date.end_of_day
      end
      result
    end
  end
end
