require 'webmock/rspec'
WebMock.disable_net_connect!

require 'committee_fetcher'

describe Parliament::CommitteeFetcher, ".fetch" do
  let(:site) { 'data.parliament.uk' }
  let(:path) { '/resources/members/api/committees' }
  let(:url) { "http://#{site}#{path}" }
  let(:xml) { <<-XML
<committees xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:c="urn:parliament/metadata/core/2010/10/01/committee">
<c:committee id="8">
<c:committeeName>Business, Enterprise and Regulatory Reform</c:committeeName>
<c:subCommittee/>
<c:committeeType>Departmental</c:committeeType>
</c:committee>
<c:committee id="19">
  <c:committeeName>Constitutional Affairs</c:committeeName>
  <c:subCommittee/>
  <c:committeeType>Departmental</c:committeeType>
</c:committee>
</committees>
XML
  }

  it "retrieves the committee xml from the parliament.gov api" do
    stub_request(:get, url).to_return(:body => xml)
    Parliament::CommitteeFetcher.fetch
    a_request(:get, url).should have_been_made
  end

  it "parses the committee xml and creates a Committee object for each" do
    stub_request(:get, url).to_return(:body => xml)
    committees = Parliament::CommitteeFetcher.fetch
    committees.size.should == 2
    committees[0].id.should == '8'
    committees[0].name.should == 'Business, Enterprise and Regulatory Reform'
    committees[0].committee_type.should == 'Departmental'
  end
end

describe Parliament::Committee do
  let(:xml) { Nokogiri.XML(<<-XML
<committees xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:c="urn:parliament/metadata/core/2010/10/01/committee">
<c:committee id="19">
  <c:committeeName>Constitutional Affairs</c:committeeName>
  <c:subCommittee/>
  <c:committeeType>Departmental</c:committeeType>
</c:committee>
</committees>
XML
                          ).xpath('//c:committee').first}

  let(:committee) { Parliament::Committee.new(xml) }
  let(:site) { 'data.parliament.uk' }
  let(:path) { '/resources/members/api/committees/Constitutional%20Affairs/19/' }
  let(:url) { "http://#{site}#{path}" }

  describe "#commons_member_path" do
    before do
      stub_request(:get, url).to_return(:body => xml)
    end

    it "includes the name and id" do
      committee.commons_member_path.should == "/resources/members/api/committees/Constitutional%20Affairs/19/members/commons"
    end
  end

  describe "#lords_member_path" do
    before do
      stub_request(:get, url).to_return(:body => xml)
    end

    it "includes the name and id" do
      committee.lords_member_path.should == "/resources/members/api/committees/Constitutional%20Affairs/19/members/lords"
    end
  end

  describe "#members" do
  let(:committee_xml) { <<-XML
<committees xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:c="urn:parliament/metadata/core/2010/10/01/committee">
<c:committee id="19">
  <c:committeeName>Constitutional Affairs</c:committeeName>
  <c:subCommittee/>
  <c:committeeType>Departmental</c:committeeType>
</c:committee>
</committees>
XML
  }

    let(:commons_xml) { <<-XML
<commonsMembers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ho="urn:parliament/metadata/core/2010/10/01/holder" xmlns:a="urn:parliament/metadata/core/2010/10/01/address" xmlns:m="urn:parliament/metadata/member/commons/2010/10/01" xmlns:pp="urn:parliament/metadata/core/2010/10/01/parliamentarypost" xmlns:p="urn:parliament/metadata/core/2010/10/01/party" xmlns:c="urn:parliament/metadata/core/2010/10/01/constituency" xmlns:op="urn:parliament/metadata/core/2010/10/01/oppositionpost" xmlns:ms="urn:parliament/metadata/core/2010/10/01/maidenspeech" xmlns:g="urn:parliament/metadata/core/2010/10/01/gender" xmlns:s="urn:parliament/metadata/core/2010/10/01/status" xmlns:gp="urn:parliament/metadata/core/2010/10/01/governmentpost" xmlns:h="urn:parliament/metadata/core/2010/10/01/honour">
<m:commonsMember m:id="227" m:dodsId="25653" m:website="http://www.andrewgeorge.org.uk">
<p:party id="17">
<p:partyName>Liberal Democrat</p:partyName>
<p:partyAbbrev>LD</p:partyAbbrev>
<p:subType/>
</p:party>
<c:constituency id="3769">
<c:constituencyName>St Ives</c:constituencyName>
<c:constituencyType>County</c:constituencyType>
<c:country>England</c:country>
<c:areaType>Shire district</c:areaType>
</c:constituency>
<g:gender id="1">Male</g:gender>
</m:commonsMember>
</commonsMembers>
  XML
    }

    let(:lords_xml) { <<-XML
<peers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ho="urn:parliament/metadata/core/2010/10/01/holder" xmlns:a="urn:parliament/metadata/core/2010/10/01/address" xmlns:m="urn:parliament/metadata/member/lords/2010/10/01" xmlns:pp="urn:parliament/metadata/core/2010/10/01/parliamentarypost" xmlns:p="urn:parliament/metadata/core/2010/10/01/party" xmlns:c="urn:parliament/metadata/core/2010/10/01/constituency" xmlns:op="urn:parliament/metadata/core/2010/10/01/oppositionpost" xmlns:ms="urn:parliament/metadata/core/2010/10/01/maidenspeech" xmlns:g="urn:parliament/metadata/core/2010/10/01/gender" xmlns:s="urn:parliament/metadata/core/2010/10/01/status" xmlns:gp="urn:parliament/metadata/core/2010/10/01/governmentpost" xmlns:h="urn:parliament/metadata/core/2010/10/01/honour">
<m:peer id="1767" pimsId="4681" dodsId="26770" website="">
<m:type>Life peer</m:type>
<m:rank>Lord</m:rank>
<m:firstName>Patrick</m:firstName>
<m:lastName>Wright</m:lastName>
<m:shortTitle/>
<m:longTitle>Test Long Title</m:longTitle>
<g:gender id="1">Male</g:gender>
<p:party id="6">
<p:partyName>Crossbench</p:partyName>
<p:partyAbbrev>XB</p:partyAbbrev>
<p:grouping/>
</p:party>
<s:status>
<s:name>Active</s:name>
<s:statusInformation xsi:type="s:Active"/>
</s:status>
<m:lastOathDate>18/05/2010</m:lastOathDate>
</m:peer>
</peers>
  XML
    }

    before do
      stub_request(:get, url + 'members/lords').to_return(:body => lords_xml)
      stub_request(:get, url + 'members/commons').to_return(:body => commons_xml)
      Parliament::MemberFetcher.stub(:fetch_all).and_return({
        '227' => Parliament::Member.new('227', "Test Person")
      })
      stub_request(:get, "http://#{site}/resources/members/api/committees/Constitutional%20Affairs/19/").to_return(:body => committee_xml)
    end

    it "fetches the lords and common members" do
      committee.members
      a_request(:get, url + 'members/lords').should have_been_made
      a_request(:get, url + 'members/commons').should have_been_made
    end

    it "creates Member objects for each member" do
      members = committee.members
      members.size.should == 2
      members[0].id.should == '1767'
      members[0].name.should == "Lord Patrick Wright (Test Long Title)"
      members[1].id.should == '227'
      members[1].name.should == "Test Person"
    end
  end
end

