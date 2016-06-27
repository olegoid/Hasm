require "colored"

module Hasm
  class Compiler
    @@keywords = { 'R0'     => '000000000000000',
                   'R1'     => '000000000000001',
                   'R2'     => '000000000000010',
                   'R3'     => '000000000000011',
                   'R4'     => '000000000000100',
                   'R5'     => '000000000000101',
                   'R6'     => '000000000000110',
                   'R7'     => '000000000000111',
                   'R8'     => '000000000001000',
                   'R9'     => '000000000001001',
                   'R10'    => '000000000001010',
                   'R11'    => '000000000001011',
                   'R12'    => '000000000001100',
                   'R13'    => '000000000001101',
                   'R14'    => '000000000001110',
                   'R15'    => '000000000001111',
                   'SCREEN' => '100000000000000',
                   'KBD'    => '110000000000000',
                   'SP'     => '000000000000000',
                   'LCL'    => '000000000000001',
                   'ARG'    => '000000000000010',
                   'THIS'   => '000000000000011',
                   'THAT'   => '000000000000100' }

    @@comp = { '0'   => '101010',
               '1'   => '111111',
               '-1'  => '111010',
               'D'   => '001100',
               'A'   => '110000',
               'M'   => '110000',
               '!D'  => '001101',
               '!A'  => '110001',
               '!M'  => '110001',
               '-D'  => '001111',
               '-A'  => '110011',
               '-M'  => '110011',
               'D+1' => '011111',
               'A+1' => '110111',
               'M+1' => '110111',
               'D-1' => '001110',
               'A-1' => '110010',
               'M-1' => '110010',
               'D+A' => '000010',
               'D+M' => '000010',
               'D-A' => '010011',
               'D-M' => '010011',
               'A-D' => '000111',
               'M-D' => '000111',
               'D&A' => '000000',
               'D&M' => '000000',
               'D|A' => '010101',
               'D|M' => '010101' }

    @@dest = { 'null' => '000',
               'M'    => '001',
               'D'    => '010',
               'MD'   => '011',
               'A'    => '100',
               'AM'   => '101',
               'AD'   => '110',
               'AMD'  => '111' }

    @@jump = { 'null' => '000',
               'JGT'  => '001',
               'JEQ'  => '010',
               'JGE'  => '011',
               'JLT'  => '100',
               'JNE'  => '101',
               'JLE'  => '110',
               'JMP'  => '111' }

    def initialize(options)
      raise "No *.asm file provided".red if options[:source_file].nil?
      @source_file_path = options[:source_file]
      raise "#{@source_file_path} was not found".red unless File.exist?(@source_file_path)
    end

    # Find all label declarations and add them to labels table
    def run_first_pass
      @labels = Hash.new

      line_num=-1
      source = File.open(@source_file_path).read
      source.each_line do |line|
        next if line.start_with?('//')               # Skip comments
        next if line.to_s == '' or line.to_s == '\n' # Skip new lines and empty strings

        line.strip!

        if line.start_with?('(')
          line.tr!('()', '')
          @labels["#{line}"] = line_num - 1
          next
        end

        line_num += 1
      end

      puts @labels
      puts Hasm::TableHelper.create_table('Labels', @labels.keys)
    end

    def run_second_pass
      binary_instructions = []
      @variables = Hash.new

      line_num=-1
      source = File.open(@source_file_path).read
      source.each_line do |line|
        line_num += 1

        line.strip!

        next if line.start_with?('//')               # Skip comments
        next if line.start_with?('(')                # Skip labels definition
        next if line.to_s == '' or line.to_s == '\n' # Skip new lines and empty strings

        if line.start_with?('@')
          binary_instructions << parse_a_instruction(line)
        else
          binary_instructions << parse_c_instruction(line)
        end
      end

      puts
      puts Hasm::TableHelper.create_table('Variables', @variables.keys)

      puts
      puts binary_instructions

      file_name = File.basename(@source_file_path, ".*") # file name without extension
      open("#{file_name}.hack", 'w') { |f|
        binary_instructions.each { |bin|
          f.puts "#{bin}"
        }
      }
    end

    private

    def parse_a_instruction(instruction)
      instruction.tr!('@', '')

      instruction = instruction.split(' ').first if instruction.include? "//"

      return '0' + @@keywords["#{instruction}"] if @@keywords.key?(instruction)

      if is_number?(instruction)
        ('%0*b' % [16, instruction.to_i]).to_s
      elsif @labels.key?(instruction)
        ('%0*b' % [16, @labels["#{instruction}"]]).to_s
      else
        get_variable_address(instruction)
      end
    end

    def parse_c_instruction(instruction)
      a = '0'
      c = '000000'
      d = '000'
      j = '000'

      instruction = instruction.split(' ').first if instruction.include? "//"

      if instruction.include? ';'           # we deal with jump instruction
        comp = instruction.split(';').first
        a = '1' if comp.include? 'M'
        c = @@comp["#{comp}"] if @@comp.key?(comp)

        jmp = instruction.split(';').last
        j = @@jump["#{jmp}"] if @@jump.key?(jmp)
      else                                  # we deal with regular C instruction
        dest = instruction.split('=').first
        d = @@dest["#{dest}"] if @@dest.key?(dest)
        comp = instruction.split('=').last
        a = '1' if comp.include? 'M'
        c = @@comp["#{comp}"] if @@comp.key?(comp)
      end

      '111' + a + c + d + j
    end

    def is_number?(string)
      true if Float(string) rescue false
    end

    def get_variable_address(variable_name)
      return @variables["#{variable_name}"].to_s if @variables.key?(variable_name)
      @variables["#{variable_name}"] = ('%0*b' % [16, (@variables.count + 16)])
      @variables["#{variable_name}"]
    end
  end
end