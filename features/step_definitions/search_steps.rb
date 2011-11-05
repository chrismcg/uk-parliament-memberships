Given /^an MP named "([^"]*)" who's on the "([^"]*)"$/ do |member_name, committee_name|
  member = Member.find_or_create_by_name(member_name)
  committee = Organization.find_or_create_by_name(committee_name)
  Membership.create!(:member => member, :organization => committee)
end

When /^I search for "([^"]*)"$/ do |member_name|
  visit search_page
  fill_in search_box, :with => member_name
  click_button search_button
end

Then /^I should see "([^"]*)"$/ do |name|
  page.should have_content(name)
end
