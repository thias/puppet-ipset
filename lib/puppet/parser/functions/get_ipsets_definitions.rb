module Puppet::Parser::Functions
    newfunction(:get_ipsets_definitions, :type => :rvalue) do |args|
        
        url = args[0]

        ipsets = function_get_ipsets_from_consul( [url] )

        ipset_definitions = {}

        ipsets.each do |ipsetName, ips| 
            
            ipset_definitions[ipsetName] = {
                "from_file" => "/opt/ipsets/#{ipsetName}.zone",
                "ipset_type"=> "hash:net"
            }

        end 

        ipset_definitions
    end
 end