module Puppet::Parser::Functions
    newfunction(:get_ipsets_from_consul, :type => :rvalue) do |args|
       
        require 'net/http'
        require 'json'
        require "base64"
        
        # get url from args
        url = args[0]
        
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        
        responseBodyParsed = ""
        if response.code === "200"
            responseBodyParsed = JSON.parse(response.body)    
        else
            raise response.message
        end
        
        # responses from consul API come as base64 encoded
        responseBodyDecoded = Base64.decode64(responseBodyParsed.first["Value"])
        
        # get parsed version of the config as a hash
        ipsets = JSON.parse(responseBodyDecoded)
        
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



    