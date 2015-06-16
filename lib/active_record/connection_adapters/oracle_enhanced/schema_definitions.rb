module ActiveRecord
  module ConnectionAdapters
    #TODO: Overriding `aliased_types` cause another database adapter behavior changes
    #It should be addressed by supporting `create_table_definition`
    class TableDefinition
      private
      def aliased_types(name, fallback)
        fallback
      end
    end

    module OracleEnhanced

      class ForeignKeyDefinition < ActiveRecord::ConnectionAdapters::ForeignKeyDefinition
      end

      class SynonymDefinition < Struct.new(:name, :table_owner, :table_name, :db_link) #:nodoc:
      end

      class IndexDefinition < ActiveRecord::ConnectionAdapters::IndexDefinition
        attr_accessor :table, :name, :unique, :type, :parameters, :statement_parameters, :tablespace, :columns
 
        def initialize(table, name, unique, type, parameters, statement_parameters, tablespace, columns)
          @table = table
          @name = name
          @unique = unique
          @type = type
          @parameters = parameters
          @statement_parameters = statement_parameters
          @tablespace = tablespace
          @columns = columns
          super(table, name, unique, columns, nil, nil, nil, nil)
        end
      end

      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition

        def raw(name, options={})
          column(name, :raw, options)
        end

        def virtual(* args)
          options = args.extract_options!
          column_names = args
          column_names.each { |name| column(name, :virtual, options) }
        end

        def column(name, type, options = {})
          if type == :virtual
            default = {:type => options[:type]}
            if options[:as]
              default[:as] = options[:as]
            elsif options[:default]
              warn "[DEPRECATION] virtual column `:default` option is deprecated.  Please use `:as` instead."
              default[:as] = options[:default]
            else
              raise "No virtual column definition found."
            end
            options[:default] = default
          end
          super(name, type, options)
        end

      end
    end
  end
end
