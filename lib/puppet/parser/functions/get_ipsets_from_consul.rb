module Puppet::Parser::Functions
    newfunction(:get_ipsets_from_consul, :type => :rvalue) do |args|
       
        require 'net/http'
        require 'json'
        require "base64"
        
        # get config from args
        url = args[0]
        defaultbundle = args[1]
        rolebundle = args[2]
        bulkdenyglobalbundleprefix = args[3]
        bulkdenyrolebundleprefix = args[4]

        # get tabled data for generic "ipsets" bundle 
        ipsets = function_get_table_data([url + defaultbundle])
        
        # add role-specific tabled ipsets (ipsets_$server_role) if available
        roleIpsets = function_get_table_data([url + rolebundle])
        if !roleIpsets.empty?
            ipsets = ipsets.merge(roleIpsets)
        end

        # add global bulk deny ipsets if available
        globalBulkDenyIpsets = function_get_bulkdeny_array_data([url + bulkdenyglobalbundleprefix])
        if !globalBulkDenyIpsets.empty?
            ipsets = ipsets.merge(globalBulkDenyIpsets)
        end
        
        # add role-specific bulk deny ipsets if available
        roleBulkDenyIpsets = function_get_bulkdeny_array_data([url + bulkdenyrolebundleprefix])
        if !roleBulkDenyIpsets.empty?
            ipsets = ipsets.merge(roleBulkDenyIpsets)
        end
        
        ipsets
    end
end



    