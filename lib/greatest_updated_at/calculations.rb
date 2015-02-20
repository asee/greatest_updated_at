module GreatestUpdatedAt
  module Calculations
    # a dumb method for getting the most recently updated date from the named tables.
    # Note that if the tables are not selected in your query as named you will receive an error.
    def greatest_updated_at_from_tables(table_names)
      self.pluck(greatest_select_val(table_names)).first
    end
    
    # Make an attempt to get the most recently updated record out of all the
    # included (aka preloaded) records
    def greatest_updated_at
      # Force everything included to be in the query via LEFT OUTER JOIN
      relation = self.eager_load(self.includes_values)
      
      # This is an unrolling of find_with_associations - we want to 
      # load up the join_dependency, inspect it, and select our own columns
      including = relation.eager_load_values + relation.includes_values
      join_dependency = ActiveRecord::Associations::JoinDependency.new(relation.klass, including, relation.joins_values)
      
      # inspect it for the tables of interest
      arel_tables = join_dependency.join_root.children.collect(&:tables).flatten
      table_names = arel_tables.collect(&:name) | [relation.klass.table_name]
      # note our own columns to select
      relation.select_values = [ greatest_select_val(table_names) ]
      
      # apply the dependency like find_with_associations would have
      relation = apply_join_dependency(relation, join_dependency)
      
      arel = relation.arel
      
      relation.klass.connection.select_value(arel, 'SQL', arel.bind_values + relation.bind_values)
    end
    
    protected
    def greatest_select_val(table_names)
      max_calcs = Array(table_names).collect{|name|
        "MAX(#{connection.quote_table_name(name.to_s)}.#{connection.quote_column_name("updated_at")})"
      }
      
      if max_calcs.length == 1
        max_calcs.first
      else
        "GREATEST(#{max_calcs.join(", ")})"
      end
    end
    
  end
end