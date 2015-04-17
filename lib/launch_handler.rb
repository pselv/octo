class LaunchHandler
	def self.handle(saka_request)
		# TODO dedup builder
		output = "Hello, what would you like to cook?"	
		response_body = {"response" => {"outputSpeech" => {"type" => "string", "text" => output}, "shouldEndSession" => false}}
    	response_body["version"] = saka_request["version"]
    	response_body["sessionAttributes"] = (saka_request['session'] || {})['attributes'] || {}
    	response_body
	end
end