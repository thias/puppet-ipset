module Puppet::Parser::Functions
    newfunction(:get_ipsets_firewall_rules, :type => :rvalue) do |args|
        
        ipsets = function_get_ipsets_from_consul( [args[0], args[1], args[2], args[3]] )

        ipset_firewall = {}

        ipsets.each do |ipsetName, ips| 
    
            name = ipsetName.split("_")[0]
            rule = ipsetName.split("_")[1]
            priority = ipsetName.split("_")[2]
            
            ipset_firewall["#{priority} #{name}_#{rule}"] = {
                "ipset" => "#{ipsetName} src",
                "action"=> (case rule when "a" then "accept" when "d" then "drop" end)
            }
        end 

        ipset_firewall
        
    end
 end