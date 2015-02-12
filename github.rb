#!/usr/bin/ruby

require 'rubygems'
require 'httparty'

#
# Personal Dashboard for Github
#
module Dashboard
  # Your github username and the access token from Github.com should be included
  # in your YAML configuration file. The Accept header ties us to Github's beta
  # moondragon API.
  module Config
    config  = YAML.load_file('github.yml')
    HEADERS = {
      'User-Agent'    => config['username'],
      'Accept'        => 'application/vnd.github.moondragon-preview+json',
      'Authorization' => "token #{config['access_token']}"
    }
  end
  # I might have addtional services that will be plugged into my GeekTool
  # dashboard. But I am starting with Github.
  module Github
    # HTTParty get, passing in our configuration headers for auth + new API.
    def get(url)
      HTTParty.get(url, headers: Dashboard::Config::HEADERS)
    end

    def print_repository(repository)
      print "\n"
      print "  Repository: #{repository['name']}".ljust(106)
      if repository['has_issues']
        issues     = get(repository['url'] + '/issues')
        milestones = get(repository['url'] + '/milestones')
        print " Milestones: #{milestones.count} Issues: #{issues.count}\n"
        print_milestones_and_issues(milestones, issues)
      else
        print " ===== ISSUES NOT CONFIGURED =====\n"
      end
    end

    # Print a repository's milestones and issues.
    def print_milestones_and_issues(milestones, issues)
      milestones.each do |milestone|
        print_milestone(milestone, issues)
      end
      print "    Unscheduled Issues:\n"
      issues.each { |issue| print_issue(issue) if issue['milestone'].nil? }
    end

    # Print the mileston information.
    def print_milestone(milestone, issues)
      # p milestone
      print "    Milestone: #{milestone['title']}\n"
      issues.each do |issue|
        if !issue['milestone'].nil? &&
           issue['milestone']['number'] == milestone['number']
          print_issue(issue)
        end
      end
    end

    # Print the issue and the associated user.
    def print_issue(issue, indent = 6)
      output  = ' ' * indent
      output += "Issue: #{issue['title']}".ljust(100)
      output += " User: #{issue['user']['login']}\n"
      print output
    end

    module_function :get, :print_issue, :print_milestone,
                    :print_milestones_and_issues, :print_repository
  end
end

# Script Body

organizations = Dashboard::Github.get('https://api.github.com/user/orgs')
organizations.each do |organization|
  print "Organization: #{organization['login']}\n"
  repositories = Dashboard::Github.get(organization['repos_url'])
  repositories.each do |repository|
    Dashboard::Github.print_repository(repository)
  end
end

print "\n"
print "My Issues:\n"

issues = Dashboard::Github.get('https://api.github.com/user/issues')
issues.each do |issue|
  Dashboard::Github.print_issue(issue, 2)
end
