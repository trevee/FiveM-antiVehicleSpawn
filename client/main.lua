Citizen.CreateThread(function()
  local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }
  
  local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
  end
  
  function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
  end

  function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end

  while true do 
    Citizen.Wait(750);

    for vehicle in EnumerateVehicles() do
      local script = GetEntityScript(vehicle);

      if script == nil then
        goto continue;
      end

      if not table.contains(settings.vehicle.allowedScript, script) then
        DeleteEntity(vehicle);

        if settings.debug then
          print("Vehicle with script " .. script .. " was deleted.");
        end
        goto continue;
      end

      ::continue::
    end
  end
end);