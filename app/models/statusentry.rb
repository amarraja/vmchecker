class Statusentry < ActiveRecord::Base
  attr_accessible :parsed_staus, :raw_body


  def self.create_update_for_postcode(postcode)
    checker = Checker.new(postcode).get_content
    create!(:parsed_staus => checker.boradband_status, :raw_body => checker.raw)
  end

  def parsed_status
    self.parsed_staus
  end

end

class Checker
  include HTTParty
  base_uri "https://my.virginmedia.com"

  def initialize(postcode)
    @postcode = postcode
  end

  def get_content
    response = self.class.post('/faults/service-status', body: {
      postCode: @postcode
    })
    VmContent.new(response.body)
  end
end

class VmContent

  attr_reader :boradband_status
  attr_reader :raw

  def initialize raw
    @raw = raw
    @doc = Nokogiri::HTML(raw)
    parse
  end

  def parse
    broadband_row = @doc.at_xpath("//table[@class='service-status-table']//span[@class='service-icon-med Broadband']").parent.parent
    puts broadband_row
    status_node = broadband_row.at_xpath(".//td[@class='status-content']/span")[:class]
    @boradband_status = status_node
  end

end
