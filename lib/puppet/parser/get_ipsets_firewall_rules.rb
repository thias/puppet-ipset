module Puppet::Parser::Functions
    newfunction(:get_ipsets_firewall_rules, :type => :rvalue) do |args|
        
        raw_ipsets = args[0]

        ipsets = function_crunch_conan_ipsets_data( [raw_ipsets] )

        ipset_firewall = {}

        ipsets.each do |ipsetName, ips| 
    
            priority = ipsetName.split("_")[2]
            
            ipset_firewall["#{priority} - #{ipsetName} Ipset"] = {
                "ipset" => "#{ipsetName} src",
                "action"=> "accept"
            }
        end 

        ipset_firewall
        
    end
 end