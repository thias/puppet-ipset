module Puppet::Parser::Functions
    newfunction(:get_ipsets_from_consul, :type => :rvalue) do |args|
       
        require 'net/http'
        require 'json'
        require "base64"
        
        # get config from args
        url = args[0]
        defaultbundleurl = args[0] + args[1]
        rolebundleurl = args[0] + args[2]
        bulkdenyglobalbundleprefixurl = args[0] + args[3]
        bulkdenyrolebundleprefixurl = args[0] + args[4]

        # get tabled data for generic "ipsets" bundle 
        ipsets = function_get_table_data([defaultbundleurl])
        
        # add role-specific tabled ipsets (ipsets_$server_role) if available
        roleIpsets = function_get_table_data([rolebundleurl])
        if !roleIpsets.empty?
            ipsets = ipsets.merge(roleIpsets)
        end

        # add global bulk deny ipsets if available
        globalBulkDenyIpsets = function_get_bulkdeny_array_data([bulkdenyglobalbundleprefixurl])
        if !globalBulkDenyIpsets.empty?
            ipsets = ipsets.merge(globalBulkDenyIpsets)
        end
        
        # add role-specific bulk deny ipsets if available
        roleBulkDenyIpsets = function_get_bulkdeny_array_data([bulkdenyrolebundleprefixurl])
        if !roleBulkDenyIpsets.empty?
            ipsets = ipsets.merge(roleBulkDenyIpsets)
        end
        
        ipsets
    end
end



    