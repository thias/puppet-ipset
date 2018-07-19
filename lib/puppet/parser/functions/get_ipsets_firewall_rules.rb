module Puppet::Parser::Functions
    newfunction(:get_ipsets_firewall_rules, :type => :rvalue) do |args|
        
        ipsets = function_get_ipsets_from_consul( [args[0], args[1], args[2], args[3]] )

        ipset_firewall = {}

        ipsets.each do |ipsetName, ips| 
    
            priority = ipsetName.split("|")[2]
            
            ipset_firewall["#{priority} #{ipsetName}"] = {
                "ipset" => "#{ipsetName} src",
                "action"=> "accept"
            }
        end 

        ipset_firewall
        
    end
 end