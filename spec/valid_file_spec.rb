require 'spec_helper'
require_relative '../valid_file.rb'

describe 'ValidFile' do
    let!(:csv_data) { CSV.parse(File.read('./clients_v2.csv'), headers: true) }
    let(:new_csv) { ValidFile.new(csv_data).validate_data }
    context "Get valid filtered data" do
        it "return filtered data" do
            expect(csv_data.length).to eq(10)
            expect(new_csv.length).to eq(4)
        end
        
        it "remove missing data" do
            expect(csv_data.find{|data| data['First Name'] == 'Darcy'}).to eq(csv_data[0])
            expect(new_csv.find{|data| data['First Name'] == 'Darcy'}).to be_nil
        end

        it "remove postal code not found data" do
            expect(csv_data.find{|data| data['First Name'] == 'Georgia'}).to eq(csv_data[1])
            expect(new_csv.find{|data| data['First Name'] == 'Georgia'}).to be_nil
        end

        it "return latitude and longitude" do
            expect(new_csv[0]['Email']).to eq('jaime_kuphal@yahoo.com')
            expect(new_csv[0]['Residential Latitude']).should_not be_nil
            expect(new_csv[0]['Residential Logitude']).should_not be_nil
            expect(new_csv[0]['Postal Latitude']).should_not be_nil
            expect(new_csv[0]['Postal Longitude']).should_not be_nil
        end
    end
end