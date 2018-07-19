module Puppet::Parser::Functions
    newfunction(:get_ipsets_from_consul, :type => :rvalue) do |args|
       
        require 'net/http'
        require 'json'
        require "base64"
        
        # get config from args
        url = args[0]
        defaultbundle = args[1]
        rolebundle = args[2]
        bulkdenybundleprefix = args[3]

        # Get ipsets from default bundle
        # ------------------------------
        uri = URI.parse(url + defaultbundle)
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

        # ------------------------------

        # Get ipsets from role-specific bundle
        # ------------------------------
        uri = URI.parse(url + rolebundle)
        response = Net::HTTP.get_response(uri)
        
        if response.code === "200"
            
            responseBodyParsed = JSON.parse(response.body)  
            
            # responses from consul API come as base64 encoded
            responseBodyDecoded = Base64.decode64(responseBodyParsed.first["Value"])
            
            # get parsed version of the config as a hash
            roleipsets = JSON.parse(responseBodyDecoded)  
            
            # add the role-specific ipsets config to the default one
            ipsets = ipsets.merge(roleipsets)

        elsif response.code === "404"
            # drop a message to the logs if no role-specific bundle has been found
            # that's non-breaking and expected for most roles
            debug("No role-specific bundle with ipsets for role #{rolebundle} in Consul. This might be expected.")
        else
            raise response.message
        end
        
        # ------------------------------

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
                        debug("Ipset #{ipset_name} has ip defined with rule that is not either accept or drop. Skipping its processing..")
                    end

                end
            end
        end


        # Get ipsets from bulk deny bundles
        # ------------------------------

        # discover the available keys (all that start with the bulkdenybundleprefix)
        uri = URI.parse(url + bulkdenybundleprefix + "?keys")
        response = Net::HTTP.get_response(uri)
        
        if response.code === "200"
            
            bundlesList = JSON.parse(response.body)  
            
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
                    ipset_name = ipset_name.gsub("ipsets.bulkdeny.", "") + "_d_095"
                    unless ipsetsGroupedByRuleAndPriority[ipset_name]
                        ipsetsGroupedByRuleAndPriority[ipset_name] = []
                    end
                    ipsetsGroupedByRuleAndPriority[ipset_name] = ips
                end

            end
            
            # add the role-specific ipsets config to the default one
            ipsets = ipsets.merge(roleipsets)

        elsif response.code === "404"
            # drop a message to the logs if no bulkdeny bundles has been found
            # that's non-breaking
            debug("No bulk deny bundles with ipsets in Consul. This might be expected.")
        else
            raise response.message
        end
        
        # ------------------------------

        ipsetsGroupedByRuleAndPriority
    end
end



    