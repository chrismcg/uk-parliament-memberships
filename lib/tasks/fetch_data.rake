namespace :data do
  desc "Fetch the data"
  task :fetch => :environment do
    require './lib/committee_fetcher'
    puts "Clearing existing data"
    Member.delete_all
    Organization.delete_all
    Membership.delete_all
    puts "Fetching committees"
    Parliament::CommitteeFetcher.fetch.each do |committee|
      puts "=" * 80
      puts committee.name
      organization = Organization.find_or_create_by_name(committee.name, :parliament_id => committee.id)
      committee.members.each do |member|
        puts member.name
        m = Member.find_or_create_by_name(member.name, :parliament_id => member.id)
        organization.members << m
      end
      puts ""
    end
  end
end
