require 'commander'

module Hasm
  class CommandGenerator
    include Commander::Methods

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :version, Hasm::VERSION
      program :description, Hasm::DESCRIPTION
      program :help, "Author", "Oleg Demchenko <gracehood@mail.ru>"
      program :help, "Website", "https://github.com/olegoid"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

      command :compile do |c|
        c.syntax = "hasm compile"
        c.description = "Translates program written in Hack symbolic language to binary codes of Hack machine"

        c.option '--source-file STRING', String, 'Path to *.asm file'

        c.action do |_args, options|
          Hasm::Compiler.new(convert_options(options))
        end

        default_command :compile

        run!
      end
    end
  end
end
