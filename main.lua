--main.lua

require("mobdebug").start()

local Util = require "Twilio.Util"

local url = "sip:stew@bracken.com"
print (Util.url_encode(url))

require "tests.test_TwilioRestClient"
