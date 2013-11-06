-- test for TwilioRestClient

local Rest = require "Twilio.TwilioRestClient"


local json = require("json")

--URL
local ACCOUNT_SID = ""
local ACCOUNT_TOKEN = ""
  
--Outgoing Caller ID previously validated with Twilio
local CALLER_TO = "+19254877855"
local CALLER_FROM = "+19252415938"
local r = Rest.create(ACCOUNT_SID,ACCOUNT_TOKEN)

local vars={}

local function callback(event)
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
--r:request(vars, "POST", callback)

--Make an invalid call
vars.From = nil
r:request(vars, "POST", callback)

--Send a message
vars = {Type="Messages", From=CALLER_FROM, To = CALLER_TO, Body="You are looking sooo good today!"}
r:request(vars,"POST", callback)