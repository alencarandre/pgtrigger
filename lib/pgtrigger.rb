require "pgtrigger/version"

module ActiveRecord
  class Migration
    def create_trigger(table_name, trigger_name, after: nil, before: nil)
      raise "Not defined after or before for create_trigger" unless after || before
      raise "Define only on after or before" if after && before

      trigger_name = build_trigger_name(table_name, trigger_name)
      execute(<<-TRIGGERSQL
          CREATE OR REPLACE FUNCTION #{trigger_name}_func()
            RETURNS trigger
            LANGUAGE plpgsql
          AS $function$
          BEGIN
            #{yield}
          END;
          $function$
        TRIGGERSQL
      )

      after = after.join(" OR ") if ["Array"].include?(after.class.to_s)
      after = "AFTER #{after}" if after

      before = before.join(" OR ") if ["Array"].include?(before.class.to_s)
      before = "BEFORE #{before}" if before

      execute(<<-TRIGGERSQL
          CREATE TRIGGER #{trigger_name}_trigger
            #{after} #{before} ON #{table_name}
            FOR EACH ROW EXECUTE PROCEDURE #{trigger_name}_func()
        TRIGGERSQL
      )
    end

    def remove_trigger(table_name, trigger_name = nil)
      trigger_name = build_trigger_name(table_name, trigger_name)

      execute("DROP TRIGGER IF EXISTS #{trigger_name}_trigger ON #{table_name};")
      execute("DROP FUNCTION IF EXISTS #{trigger_name}_func();")
    end

    private

    def build_trigger_name(table_name, trigger_name)
      "#{trigger_name}_#{table_name}"
    end
  end

  module PgTriggerSchemaDumperSuport
    def trailer(stream)
      triggers = mount_trigger_schema

      if triggers.present?
        triggers = "\n\t#{triggers.join("\n\t")}"
        if(@dump.respond_to?(:final))
          @dump.final << triggers
        else
          stream.puts triggers
        end
      end

      super(stream)
    end

    private

    def mount_trigger_schema
      triggers = []

      discovery_triggers.each do |trigger|
        trigger_name = trigger["trigger_name"][0..-9]
        table_name = trigger["event_object_table"]

        triggers << "create_trigger '#{table_name}', '#{trigger_name}'"
      end

      triggers
    end

    def discovery_triggers
      sql = <<-DETECTTRIGGER
        SELECT
          *
        FROM information_schema.triggers
        WHERE trigger_schema = current_schema();
      DETECTTRIGGER
      result = @connection.execute(sql)
    end
  end

  class SchemaDumper
    prepend PgTriggerSchemaDumperSuport
  end
end
