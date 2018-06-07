module Puppet::Parser::Functions
    newfunction(:get_ipsets_files, :type => :rvalue) do |args|
        
        raw_ipsets = args[0]

        ipsets = function_crunch_conan_ipsets_data( [raw_ipsets] )

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