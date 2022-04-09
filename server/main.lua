RegisterCommand(Config.JobsCommand, function(source, args)
    if Config.UseAcePerms then
        if IsPlayerAceAllowed(source, "taxijob") then
            TriggerClientEvent('TaxiJob:SetActiveDriver', source)
        else 
            TriggerClientEvent('TaxiJob:Error', source, 'You do not have permissions to do that!')
        end
    else
        TriggerClientEvent('TaxiJob:SetActiveDriver', source)
    end
end)