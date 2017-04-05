require 'nokogiri'
require 'open-uri'

class PlaylistsData
  def self.import(channel_id)
    # (1..2).each do |week_day|
    week_day = 1
      url = "http://web6.tvmao.com/program/CCTV-CCTV1-w#{week_day}.html"
      # puts url
      page = Nokogiri::HTML(open(url))
      puts '---------------------------------------------------------------'
      puts page.css('ul#pgrow li')
    # end
  end
end