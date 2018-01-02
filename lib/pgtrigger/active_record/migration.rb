module ActiveRecord
  class Migration
    def create_trigger(table_name, trigger_name, after: nil, before: nil, declare: nil)
      raise "Not defined after or before for create_trigger" unless after || before
      raise "Define only on after or before" if after && before

      trigger_name = Pgtrigger::Utils.build_trigger_name(table_name, trigger_name)

      if declare
        declare = "DECLARE \n\t\t#{declare.map{|var| var.to_a.join(" ")}.join(";\n\t\t")};"
      end

      execute(<<-TRIGGERSQL
          CREATE OR REPLACE FUNCTION #{trigger_name}_func()
            RETURNS trigger
            LANGUAGE plpgsql
          AS $function$
          #{declare}
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
      trigger_name = Pgtrigger::Utils.build_trigger_name(table_name, trigger_name)

      execute("DROP TRIGGER IF EXISTS #{trigger_name}_trigger ON #{table_name};")
      execute("DROP FUNCTION IF EXISTS #{trigger_name}_func();")
    end
  end
end
