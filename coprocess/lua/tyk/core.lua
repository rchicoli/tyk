print("Loading core")

local cjson = require "cjson"

-- TODO: Cache additional modules
tyk = {
  req=require("coprocess.lua.tyk.request")
}

-- Make the current object accessible for helpers.
object = nil

function dispatch(raw_object)
  object = cjson.decode(raw_object)

  -- Environment reference to hook.
  hook_name = object['hook_name']
  hook_f = _G[hook_name]
  is_custom_key_auth = false

  -- Set a flag if this is a custom key auth hook.
  if object['hook_type'] == 4 then
    is_custom_key_auth = true
  end

  -- Call the hook and return a serialized version of the modified object.
  if hook_f then
    local new_request, new_session, metadata

    if custom_key_auth then
      new_request, new_session, metadata = hook_f(object['request'], object['session'], object['metadata'], object['spec'])
    else
      new_request, new_session = hook_f(object['request'], object['session'], object['spec'])
    end

    -- Modify the CP object.
    object['request'] = new_request
    object['session'] = new_session
    object['metadata'] = metadata

    raw_new_object = cjson.encode(object)

    return raw_new_object, #raw_new_object

  -- Return the original object and print an error.
  else
    print("Lua: hook doesn't exist!")
    return raw_object, #raw_object
  end

end