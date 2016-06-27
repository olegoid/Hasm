require 'terminal-table'

module Hasm
  class TableHelper
    def self.create_table(header, items)
      rows = []
      items.each do |item|
        rows << [item]
      end

      Terminal::Table.new :headings => [header], :rows => rows
    end
  end
end