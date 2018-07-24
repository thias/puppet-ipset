module Puppet::Parser::Functions
    newfunction(:get_ipsets_definitions, :type => :rvalue) do |args|
        
        ipsets = function_get_ipsets_from_consul( [args[0], args[1], args[2], args[3], args[4], args[5]] )

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