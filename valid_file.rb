#!/usr/bin/env ruby
require 'csv'
require 'geocoder'

class ValidFile
  attr_accessor :csv_data, :detail
  def initialize(csv_data)
    @csv_data = csv_data
    @locations = {}
  end

  def validate_data
    headers = csv_data.headers
    headers.insert(7, 'Residential Latitude')
    headers.insert(8, 'Residential Logitude')
    headers += ['Postal Latitude', 'Postal Longitude']
    CSV.open("output.csv", "w", write_headers: true, headers: headers) do |writer|
      @csv_data.each do |detail|
        @detail = detail
        csv = detail.to_h
        next unless !check_data_existance
        residential_address = residential_location
        postal_address = postal_location
        next if check_address(residential_address, detail['Residential Address Postcode'])
        next if check_address(postal_address, detail['Postal Address Postcode'])
        csv['Residential Latitude'] = residential_address&.lat
        csv['Residential Logitude'] = residential_address&.lon
        csv['Postal Latitude'] = postal_address&.lat
        csv['Postal Longitude'] = postal_address&.lon
        writer << csv
      end
    end
    CSV.parse(File.read('output.csv'), headers: true)
  end

  private

  def check_data_existance
    existence_keys.any?{|key| detail[key].nil? }
  end

  def check_address(geo_address, postal_code)
    geo_address&.address&.[]('postcode').nil? ||
    geo_address&.address&.[]('postcode') != postal_code ||
    geo_address&.lat.nil? ||
    geo_address&.lon.nil?
  end

  def residential_location
    address = "#{detail['Residential Address Locality']} #{detail['Residential Address State']}"
    return @locations[address] unless @locations[address].nil?

    geo_location = Geocoder.search(address)&.[](0)&.data
    @locations[address] = OpenStruct.new(geo_location)
  end

  def postal_location
    address = "#{detail['Postal Address Locality']} #{detail['Postal Address State']}"
    return @locations[address] unless @locations[address].nil?

    geo_location = Geocoder.search(address)&.[](0)&.data
    @locations[address] = OpenStruct.new(geo_location)
  end

  def existence_keys
    [
      'Email', 'First Name', 'Last Name',
      'Residential Address Locality', 'Residential Address State',
      'Residential Address Postcode', 'Residential Address Postcode',
      'Postal Address Street', 'Postal Address Locality',
      'Postal Address State', 'Postal Address Postcode'
    ]
  end
end
