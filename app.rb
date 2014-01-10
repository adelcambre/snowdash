require 'sinatra/base'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'haml'
require 'json'

module Snowdash
  COLUMNS = [
    "Month",
    "Day",
    "Time",
    "Temp 6540",
    "Temp 5380",
    "RH 6540",
    "RH 5380",
    "Wind Speed",
    "Gust",
    "Wind Direction",
    "1hr Precip",
    "24hr Precip",
    "Snow since 5am",
    "Snow Base Depth",
    "Pressure"
  ]

  class App < Sinatra::Base
    def snow
      snow = Nokogiri.parse open("http://www.nwac.us/weatherdata/mthoodmeadows/now/")
      snow = snow.css(".weather-content").first.text

      snow = snow.split("\n")
      while line = snow.shift
        if line[0] == '-'
          break
        end
      end
      snow.shift

      [].tap do |out|
        while line = snow.shift
          if line.strip.empty?
            break
          end
          out << line.split
        end
      end
    end

    get "/snow.csv" do
      content_type "text/csv"
      CSV.generate do |csv|
        csv << COLUMNS
        snow.each do |line|
          csv << line
        end
      end
    end

    get "/snow.json" do
      content_type "application/json"
      snow.to_json
    end

    get "/temp.json" do
      content_type "application/json"

      out = {"labels" => [],
             "temps" => []}
      snow.each do |line|
        out["labels"] << line[2]
        out["temps"] << line[4]
      end

      out.to_json
    end

    get "/" do
      haml :index
    end
  end
end
