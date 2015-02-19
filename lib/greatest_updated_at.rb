require 'greatest_updated_at/calculations'

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.send(:include, GreatestUpdatedAt::Calculations)
end
