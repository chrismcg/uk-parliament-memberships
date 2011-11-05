require 'webmock/rspec'
WebMock.disable_net_connect!

require 'vcr'
VCR.config do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.stub_with :webmock
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end

require 'committee_fetcher'

describe CommitteeFetcher, ".fetch" do
  let(:site) { 'data.parliament.uk' }
  let(:path) { '/resources/members/api/committees' }
  let(:url) { "http://#{site}#{path}" }

  use_vcr_cassette

  it "retrieves the committee xml from the parliament.gov api" do
    CommitteeFetcher.fetch
    a_request(:get, url).should have_been_made
  end

  it "parses the committee xml and creates a Committee object for each" do
    committees = CommitteeFetcher.fetch
    committees.size.should == 253
    committees[0].id.should == '4'
    committees[0].name.should == 'Agriculture'
    committees[0].committee_type.should == 'Departmental'
  end
end

describe Committee, "#commons_member_path" do
  let(:xml) { <<-XML
<committees xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:c="urn:parliament/metadata/core/2010/10/01/committee">
<c:committee id="7">
  <c:committeeName>Business and Enterprise Committee</c:committeeName>
  <c:subCommittee/>
  <c:committeeType>Departmental</c:committeeType>
</c:committee>
</committees>
XML
  }

  before do
    @xml = Nokogiri.XML(xml).xpath('//c:committee').first
  end

  it "includes the name and id" do
    Committee.new(@xml).commons_member_path.should == "/resources/members/api/committees/Business%20and%20Enterprise%20Committee/7/members/commons"
  end
end

describe Committee, "#lords_member_path" do
  let(:xml) { <<-XML
<committees xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:c="urn:parliament/metadata/core/2010/10/01/committee">
<c:committee id="7">
  <c:committeeName>Business and Enterprise Committee</c:committeeName>
  <c:subCommittee/>
  <c:committeeType>Departmental</c:committeeType>
</c:committee>
</committees>
XML
  }

  before do
    @xml = Nokogiri.XML(xml).xpath('//c:committee').first
  end

  it "includes the name and id" do
    Committee.new(@xml).lords_member_path.should == "/resources/members/api/committees/Business%20and%20Enterprise%20Committee/7/members/lords"
  end
end
