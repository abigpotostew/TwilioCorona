-- test for TwilioRestClient

local Rest = require "Twilio.TwilioRestClient"
--My own authentication credentials are not commited to repository. Get your own!
local auth = require "tests.auth" or {}
local json = require("json")

--Plug in your twilio account credentials here in the XXXX's
local ACCOUNT_SID = auth.ACCOUNT_SID or "XXXXXXXX" -- your Account SID
local ACCOUNT_TOKEN = auth.ACCOUNT_TOKEN or "XXXXXX" --your account token
  
--Outgoing Caller phone number
local CALLER_TO = auth.CALLER_TO or "+1NNNNNNNNNN"
--Incoming Caller Phone Number, previously validated with Twilio
local CALLER_FROM = auth.CALLER_FROM or "+1NNNNNNNNNN"

local r = Rest.create(ACCOUNT_SID, ACCOUNT_TOKEN)

local vars={}

local function network_callback(event)
    if ( event.isError ) then
        print( "Network error!")
    else
        print ( "RESPONSE: " .. event.response )
        --Now we have a Lua table of the json resonse!
        local response_table = json.decode(event.response)
    end
end

--Make a call:
vars = {Type = "Calls", To = CALLER_TO, From = CALLER_FROM, Url="http://demo.twilio.com/docs/voice.xml"}
--r:request(vars, "POST", network_callback)

--Make an invalid call
vars.From = nil
--r:request(vars, "POST", network_callback)

--Send a message
vars = {Type="Messages", From=CALLER_FROM, To = CALLER_TO, Body="You are looking sooo good today!"}
r:request(vars,"POST", network_callback)


