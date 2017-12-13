require "pgtrigger/version"
require "pgtrigger/active_record/migration"
require "pgtrigger/active_record/schema_dumper"

module Pgtrigger
  class Utils
    def self.build_trigger_name(table_name, trigger_name)
      "#{trigger_name}_#{table_name}"
    end
  end
end
