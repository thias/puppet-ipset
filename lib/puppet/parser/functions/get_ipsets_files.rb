module Puppet::Parser::Functions
    newfunction(:get_ipsets_files, :type => :rvalue) do |args|
        
        ipsets = function_get_ipsets_from_consul( [args[0], args[1], args[2], args[3], args[4], args[5]] )

        ipset_files = {}

        ipsets.each do |ipsetName, ips| 
            
            ipset_files["/opt/ipsets/#{ipsetName}.zone"] = {
                "ensure"    => "file",
                "owner"     => "root",
                "group"     => "root",
                "mode"      => "0755",
                "content"   => ips * "\n"
            }

        end 

        ipset_files

    end
 end