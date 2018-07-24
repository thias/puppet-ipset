module Puppet::Parser::Functions
    newfunction(:get_table_data, :type => :rvalue) do |args|
       
        require 'net/http'
        require 'json'
        require "base64"
        
        url = args[0]
        
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        
        responseBodyParsed = ""
        if response.code === "200"
            responseBodyParsed = JSON.parse(response.body)    

            # responses from consul API come as base64 encoded
            responseBodyDecoded = Base64.decode64(responseBodyParsed.first["Value"])
            
            # get parsed version of the config as a hash
            ipsets = JSON.parse(responseBodyDecoded)

            ipsetsGroupedByRuleAndPriority = {}

            ipsets.each do |ipset_name, ipset_value| 

                # remove "ipsets." magic words from keys
                nameReplaced = ipset_name.gsub("ipsets.", "")
                
                if !ipset_value.nil?
                    ipset_value.each do |ip, details|  
                        
                        if details["rule"] == "accept" || details["rule"] == "drop" 
                            # construct the ipset name (e.g savagaming_accept_888 or savagaming_drop_045)
                            ipset_name = nameReplaced + "_" + details["rule"][0] + "_" + details["priority"]
                            
                            unless ipsetsGroupedByRuleAndPriority[ipset_name]
                                ipsetsGroupedByRuleAndPriority[ipset_name] = []
                            end

                            ipsetsGroupedByRuleAndPriority[ipset_name] << ip 
                        else
                            p "Ipset #{ipset_name} has ip defined with rule that is not either accept or drop. Skipping its processing.."
                        end

                    end
                end
            end

            ipsetsGroupedByRuleAndPriority

        elsif response.code === "404"
            # drop a message to the logs if no bundle has been found
            # that's non-breaking and expected for most roles
            p "No bundle with ipsets (#{bundle}) in Consul. This might be expected."

            # return empty hash
            {}
        else
            raise response.message
        end

    end
end



    