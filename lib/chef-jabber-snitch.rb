require 'rubygems'
require 'chef'
require 'chef/handler'
require 'net/http'
require 'uri'
require 'json'
require 'xmpp4r/client'
require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/roster'

class JabberSnitch < Chef::Handler

  def initialize(jabber_user, jabber_password, jabber_room, pastebin_server, jabber_server = 'talk.google.com', pastebin_expire = 74880, jabber_port = 5222)
    @jabber_user = jabber_user
    @jabber_password = jabber_password
    @jabber_server = jabber_server
    @jabber_room = jabber_room
    @pastebin_server = pastebin_server
    @pastebin_expire = pastebin_expire
    @jabber_port = jabber_port
    @timestamp = Time.now.getutc
  end

  def fmt_run_list
    node.run_list.map {|r| r.type == :role ? r.name : r.to_s }.join(', ')
  end

  def fmt_output
    message =  "Node: #{node.name} (#{node.ipaddress})\n"
    message << "Run list: #{node.run_list}\n"
    message << "All roles: #{node.roles.join(', ')}\n"
    message << "\n"
    message << "#{run_status.formatted_exception}\n"
    message << Array(backtrace).join("\n")
    return message
  end

  def report
    Chef::Log.debug("Starting jabber handling")
    if STDOUT.tty?
      Chef::Log.error("Chef run failed @ #{@timestamp}")
      Chef::Log.error("#{run_status.formatted_exception}")
    else
      Chef::Log.error("Chef run failed @ #{@timestamp}, snitchin' to chefs via Jabber")
    end     
    res = nil
      begin
         timeout(10) do
          res = Net::HTTP.post_form(URI.parse(@pastebin_server), {"expire" => @pastebin_expire, "text" => fmt_output, "name" => node.name, "title" => "Failed Chef run #{@timestamp}"})
          Chef::Log.info("Created output #{res.body}")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to post to pastebin server #{pastebin_server}")
      end

      message = "Chef failed on #{node.name} Run List - (#{fmt_run_list}) #{res.body}"

      begin
        Chef::Log.debug("It's jabber time")
        timeout(10) do

          chef_jid = Jabber::JID::new(@jabber_user)
          chef_client = Jabber::Client::new(chef_jid)
          chef_client.connect(@jabber_server,@jabber_port)
          chef_client.auth(@jabber_password)

          muc = Jabber::MUC::MUCClient.new(chef_client)
          muc.join(Jabber::JID::new("#{@jabber_room}/" + chef_client.jid.node))

          m = Jabber::Message::new(@jabber_room, message)
          muc.send m
          Chef::Log.info("Informed chefs via Jabber '#{message}'")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to message Chefs via Jabber")
     end
  end

end