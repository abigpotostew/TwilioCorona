--TwilioRestClient.lua

local base64 = require "Twilio.lib.Base64"
local mime = require "mime"
local json = require("json")
local Util = require "Twilio.Util"

local TwilioRestClient = setmetatable({}, nil)
TwilioRestClient.__index = TwilioRestClient

function TwilioRestClient.create(acc_sid, acc_token, base_url, api_version)
   assert(type(acc_sid)=="string", type(acc_token)=="string",
       api_version == nil or type(api_version)=="string" ,
       "Rest.create(acc_sid string, acc_token string[, api_version string]")
   base_url = base_url or "https://api.twilio.com"
   api_version = api_version or "2010-04-01"
   local rest = setmetatable({}, TwilioRestClient)
   rest.sid = acc_sid
   rest.token = acc_token
   rest.base = base_url
   rest.api_version = api_version
   return rest
end

function TwilioRestClient:request(vars, method, listener)
    assert(method=="POST" or method == "GET", "TwilioRestClient:request(vars, method)")
    vars = (vars and Util.DeepCopy(vars)) or {} --deep copy so I can modify in place
    if method == "POST" then
        local status, result = pcall(function() self:post(vars, listener)end)
        if status then 
            return result
        else
            print("Invalid POST Parameters")
            return nil
        end
    elseif method == "GET" then
        local status, result = pcall(function() self:get(vars,listener)end)
        if status then return result
        else
            print("Invalid GET parameters")
            return nil
        end
    end
end

--Simply replaces a + with the url encoded %2B,
local function formatPhoneNumber(number)
    -- use '%2B' for +
    local s,e = string.find(number,"+")
    if s then
        if s ~= 1 then return "" end --invalid number format
        return "%2B" .. number:sub(2)
    end
    return number
end

local function buildURL(client,...)
    local out = client.base .. "/" .. client.api_version .. "/Accounts/" .. client.sid
    for i,v in ipairs(arg) do
        out = out .. "/" .. tostring(v)
    end
    out = out .. ".json"
    return out
end

--Vars is a table containing body uri data ie passing
--{Url=blah.com, To=123456789} returns Url=blah.com&To=123456789
-- Used by post function
local function buildURI(vars)
    local out = ""
    local first = true
    for k,v in pairs(vars) do
        if first then
            first = false
        end
        --Prevent tables or other unwanted types
        if Util.typechk(v,"string","number") and
           Util.typechk(k,"string","number") then
            if k == "To" or k == "From" then v = formatPhoneNumber(v) end
            out = out .. (not first and "&" or "") .. tostring(k) .. "=" .. tostring(v)
        end
    end
    return out
end

function TwilioRestClient:post(vars, listener)
    local t = vars.Type
    vars.Type = nil
    local body = buildURI(vars)
    local url = buildURL(self,t)
    
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Authorization"] =  "Basic "..mime.b64(self.sid..":"..self.token)

    local params = {}
    params.headers = headers
    params.body = body
    
    network.request(url, "POST", listener, params)
end

--GET requests can optionally have an instance sid, in which
--case no body data is sent to twilio
function TwilioRestClient:get(vars, listener)
   local t = vars.Type
   local isid = vars.InstanceSid
   vars.Type = nil
   vars.InstanceSid = nil
   local url = buildURL(self, t, isid)
   local body = iid and "" or buildURI(vars)
   
   local headers = {}
   headers["Content-Type"] = "application/x-www-form-urlencoded"
   headers["Authorization"] =  "Basic "..mime.b64(self.sid..":"..self.token)
   
   local params ={headers = headers, body = body}
   
   network.request(url, "GET", listener, params)
end

return TwilioRestClient
