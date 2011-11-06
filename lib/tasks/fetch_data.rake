namespace :data do
  desc "Clear the data from the database"
  task :clear_all => :environment do
    puts "Clearing existing data"
    Member.delete_all
    Organization.delete_all
    Membership.delete_all
  end

  desc "Fetch the committee data"
  task :fetch_committees => :environment do
    require './lib/committee_fetcher'
    puts "Fetching committees"
    Parliament::CommitteeFetcher.fetch.each do |committee|
      puts "=" * 80
      puts committee.name
      organization = Organization.find_or_create_by_name(committee.name, :parliament_id => committee.id, :section => "Committee")
      committee.members.each do |member|
        puts member.name
        m = Member.find_or_create_by_name(member.name, :parliament_id => member.id)
        organization.members << m
      end
      puts ""
    end
  end

  desc "Fetch the group data"
  task :fetch_groups => :environment do
    require './lib/group_fetcher'
    puts "Fetching groups"
    Parliament::GroupFetcher.fetch.each do |group|
      puts "=" * 80
      puts group.name
      organization = Organization.find_or_create_by_name(group.name, :section => "Group", :url => group.url)
      group.members.each do |name|
        puts name
        m = Member.find_or_create_by_name(name)
        organization.members << m
      end
      puts ""
    end
  end
end
