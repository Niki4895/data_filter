#!/usr/bin/env ruby
require 'csv'
require './valid_file.rb'

def main
  csv_data = if ARGV.empty?
              $stdin.read
             else
              CSV.parse(File.read(ARGV[0]), headers: true)
             end
  ValidFile.new(csv_data).validate_data
end
  
main if __FILE__ == $PROGRAM_NAME