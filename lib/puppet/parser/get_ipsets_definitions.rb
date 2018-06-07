module Puppet::Parser::Functions
    newfunction(:get_ipsets_definitions, :type => :rvalue) do |args|
        
        raw_ipsets = args[0]

        ipsets = function_crunch_conan_ipsets_data( [raw_ipsets] )

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