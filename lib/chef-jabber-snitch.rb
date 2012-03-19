require 'rubygems'
require 'chef'
require 'chef/handler'
require 'net/http'
require 'uri'
require 'json'
require 'xmpp4r/client'

class JabberSnitch < Chef::Handler

  def initialize(jabber_user, jabber_password, jabber_to, github_user, github_token, jabber_server = 'talk.google.com')
    @jabber_user = jabber_user
    @jabber_password = jabber_password
    @jabber_server = jabber_server
    @jabber_to = jabber_to
    @github_user = github_user
    @github_token = github_token
    @timestamp = Time.now.getutc
  end

  def fmt_run_list
    node.run_list.map {|r| r.type == :role ? r.name : r.to_s }.join(', ')
  end

  def fmt_gist
    ([ "Node: #{node.name} (#{node.ipaddress})",
       "Run list: #{node.run_list}",
       "All roles: #{node.roles.join(', ')}",
       "",
       "#{run_status.formatted_exception}",
       ""] +
     Array(backtrace)).join("\n")
  end

  def report

    if STDOUT.tty?
      Chef::Log.error("Chef run failed @ #{@timestamp}")
      Chef::Log.error("#{run_status.formatted_exception}")
    else
      Chef::Log.error("Chef run failed @ #{@timestamp}, snitchin' to chefs via Jabber")

      gist_id = nil
      begin
        timeout(10) do
          res = Net::HTTP.post_form(URI.parse("http://gist.github.com/api/v1/json/new"), {
            "files[#{node.name}-#{@timestamp.to_i.to_s}]" => fmt_gist,
            "login" => @github_user,
            "token" => @github_token,
            "description" => "Chef run failed on #{node.name} @ #{@timestamp}",
            "public" => false
          })
          gist_id = JSON.parse(res.body)["gists"].first["repo"]
          Chef::Log.info("Created a GitHub Gist @ https://gist.github.com/#{gist_id}")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to create a GitHub Gist")
      end

      message = "Chef failed on #{node.name} (#{fmt_run_list}): https://gist.github.com/#{gist_id}"

      begin
        timeout(10) do
          include Jabber
          jid = Jid::new(@jabber_user)
          cl = Client::new(jid)
          cl.connect(@server,5222)
          cl.auth(@password)
          to = @jabber_user
          subject = "Chef failure"
          m = Message::new(to, message).set_type(:normal).set_id('1').set_subject(subject)
          cl.send m
          Chef::Log.info("Informed chefs via Jabber '#{message}'")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to message Chefs via Jabber")
      end
    end
  end

end