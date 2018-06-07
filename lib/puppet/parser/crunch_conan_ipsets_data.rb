module Puppet::Parser::Functions
    newfunction(:crunch_conan_ipsets_data, :type => :rvalue) do |args|
       
        require 'json'
        require "base64"

        rawipsets = args[0]

        # responses from consul API come as base64 encoded
        rawIpsetsDecoded = Base64.decode64(rawipsets.first["Value"])
        
        # get parsed version of the config as a hash
        ipsets = JSON.parse(rawIpsetsDecoded)
        
        ipsetsGroupedByRuleAndPriority = {}
        
        ipsets.each do |ipset_name, ipset_value| 

            # remove "ipsets." magic words from keys
            nameReplaced = ipset_name.gsub("ipsets.", "")
                
            ipset_value.each do |ip, details|  

                # construct the ipset name (e.g savagaming_accept or savagaming_drop)
                ipset_name = nameReplaced + "_" + details["Rule"] + "_" + details["Priority"]

                unless ipsetsGroupedByRuleAndPriority[ipset_name]
                    ipsetsGroupedByRuleAndPriority[ipset_name] = []
                end

                ipsetsGroupedByRuleAndPriority[ipset_name] << ip

            end

        end

        ipsetsGroupedByRuleAndPriority
    end
end



    