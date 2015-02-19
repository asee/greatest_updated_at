module GreatestUpdatedAt
  module Calculations
    # a dumb method for getting the most recently updated date from the named tables.
    # Note that if the tables are not selected in your query as named you will receive an error.
    def greatest_updated_at_from_tables(table_names)
      max_calcs = Array(table_names).collect{|name|
        "MAX(#{connection.quote_table_name(name.to_s.pluralize)}.#{connection.quote_column_name("updated_at")})"
      }
      
      if max_calcs.length == 1
        pluck_val = max_calcs.first
      else
        pluck_val = "GREATEST(#{max_calcs.join(",")})"
      end
      
      self.pluck(pluck_val).first

    end
    
    # Make an attempt to get the most recently updated record out of all the
    # included (aka preloaded) records
    def greatest_updated_at
      greatest_updated_at_from_tables(self.includes_values.collect{|relation| Array(relation)}.flatten << self.table_name)
    end
    
  end
end