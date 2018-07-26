module Puppet::Parser::Functions
    newfunction(:get_bulkdeny_array_data, :type => :rvalue) do |args|
       
        require 'net/http'
        require 'json'
        require "base64"
        
        url = args[0]
        prefix = args[1]
        priority = args[2]
        
        # discover the available keys (all that start with prefix)
        uri = URI.parse(url + prefix + "?keys")
        response = Net::HTTP.get_response(uri)
        
        if response.code === "200"
            
            bundlesList = JSON.parse(response.body)  
            
            ipsetsGroupedByRuleAndPriority = {}

            # get each bundle and load the ips
            bundlesList.each do |bundlepath|
                bundlekey = bundlepath.split("/").last()
                uri = URI.parse(url + bundlekey)
                response = Net::HTTP.get_response(uri)
            
                responseBodyParsed = JSON.parse(response.body)  
            
                # responses from consul API come as base64 encoded
                responseBodyDecoded = Base64.decode64(responseBodyParsed.first["Value"])
                
                # get parsed version of the config as a hash
                bulkdenyIpsets = JSON.parse(responseBodyDecoded)  
                
                bulkdenyIpsets.each do |ipset_name, ips|
                    # remove "ipsets.bulkdeny" magic words from keys and add rule and priority
                    ipset_name = ipset_name.gsub("ipsets.bulkdeny.", "") + "_d_#{priority}"
                    unless ipsetsGroupedByRuleAndPriority[ipset_name]
                        ipsetsGroupedByRuleAndPriority[ipset_name] = []
                    end
                    ipsetsGroupedByRuleAndPriority[ipset_name] = ips
                end

            end
            
            ipsetsGroupedByRuleAndPriority

        elsif response.code === "404"
            # drop a message to the logs if no bulkdeny bundles has been found
            # that's non-breaking
            p "No bulk deny bundles with prefix (#{prefix}) in Consul. This might be expected."

            # return empty hash
            {}
        else
            raise response.message
        end
        
    end
end



    