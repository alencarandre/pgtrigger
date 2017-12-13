module ActiveRecord
  module SchemaDumperSupport
    def trailer(stream)
      triggers = mount_trigger_schema.join("")

      if triggers.present?
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
        table_name = trigger["event_object_table"]
        trigger_name = trigger["trigger_name"].gsub("_#{table_name}_trigger", '')

        after_or_before = "#{trigger['action_timing'].downcase}: \"#{trigger['event_manipulation']}\""

        triggers << "\n"
        triggers << "\tcreate_trigger \"#{table_name}\", \"#{trigger_name}\", #{after_or_before} do\n"
        triggers << "<<-TRIGGERBODY\n"
        triggers << parse_trigger_body(table_name, trigger_name)
        triggers << "\nTRIGGERBODY\n"
        triggers << "\tend # create_trigger"
        triggers << "\n"
      end

      triggers
    end

    def discovery_triggers
      sql = <<-DETECTTRIGGER
        SELECT * FROM information_schema.triggers
        WHERE trigger_schema = current_schema();
      DETECTTRIGGER
      result = @connection.execute(sql)
    end

    def parse_trigger_body(table_name, trigger_name)
      procedure = discovery_trigger_method(table_name, trigger_name)
      definition = procedure["definition"]
      procedure_body = definition[definition.index("BEGIN")+5..definition.size]
      procedure_body[0..procedure_body.rindex("END") -1].strip
    end

    def discovery_trigger_method(table_name, trigger_name)
      sql = <<-DISCOVERYTRIGGERMETHOD
            SELECT
                n.nspname AS schema,
                proname AS fname,
                proargnames AS args,
                t.typname AS return_type,
                d.description,
                pg_get_functiondef(p.oid) as definition
            FROM pg_proc p
            JOIN pg_type t
              ON p.prorettype = t.oid
            LEFT OUTER
            JOIN pg_description d
              ON p.oid = d.objoid
            LEFT OUTER
            JOIN pg_namespace n
              ON n.oid = p.pronamespace
           WHERE n.nspname = current_schema()
             AND proname = '#{Pgtrigger::Utils.build_trigger_name(table_name, trigger_name)}_func'
      DISCOVERYTRIGGERMETHOD
      @connection.execute(sql).first
    end
  end

  class SchemaDumper
    prepend SchemaDumperSupport
  end
end
