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
      
      # Using this to get a list of tables included via join statements, we don't want to calculate based on those
      alias_tracker = ActiveRecord::Associations::AliasTracker.create(relation.klass.connection, relation.joins_values)
      join_tables = alias_tracker.aliases.keys
      
      if relation.eager_loading?
        relation.send(:find_with_associations) { |rel| relation = rel };nil
      end
      relation.select_values = ['1'] #placeholder while we generate the initial arel
      arel = relation.arel

      # collect the list of table names we want to get the max updated at from
      join_nodes = arel.join_sources.reject{ |join| join.kind_of?(Arel::Nodes::StringJoin) }
      table_names = join_nodes.collect{ |join|  join.left.name } 
      
      # remove the join tables and make sure the root table is present 
      table_names = (table_names - join_tables) | [relation.klass.table_name]
      
      # Clear the arel projection, it used to be a placeholder
      arel.projections = []
      
      arel.project greatest_select_val(table_names)
      
      # Get the result, and make sure it is cast the same as updated_at
      result = relation.klass.connection.select_value(arel, 'SQL', arel.bind_values + relation.bind_values)
      relation.klass.column_types["updated_at"].type_cast_from_database(result)
    end
    
    protected
    def greatest_select_val(table_names)
      max_calcs = Array(table_names).collect{|name|
        "COALESCE(MAX(#{connection.quote_table_name(name.to_s)}.#{connection.quote_column_name("updated_at")}), 0)"
      }
      
      if max_calcs.length == 1
        max_calcs.first
      else
        "GREATEST(#{max_calcs.join(", ")})"
      end
    end
    
  end
end