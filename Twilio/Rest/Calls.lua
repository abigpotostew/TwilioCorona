--Calls.lua

local Calls = setmetatable({}, nil)

function Calls.create(acc_sid, acc_token, base_url, api_version)
   assert(type(acc_sid)=="string", type(acc_token)=="string",
       api_version == nil or type(api_version)=="string" 
       "Rest.create(acc_sid string, acc_token string[, api_version string]")
   base_url = base_url or "https://api.twilio.com"
   api_version = api_version or "2010-04-01"
   local rest = {}
   setmetatable(rest, TwilioRestClient)
   rest.sid = acc_sid
   rest.token = acc_token
   rest.base = base_url
   rest.api_version = api_version
   return rest
end

function TwilioRestClient:request(self, path, method, vars)
    vars = vars or {}
    params = {}
    headers = {}
    body = {}
end
