class CookBook < Sinatra::Base

  get "/launch" do
  	content_type :json
    greeting = {text: "Hello, what would you like to do?"}
    greeting.to_json
  end
  
  post "/" do
  	content_type :json
    request_body = JSON.parse request.body.read
    response_body = handle_request(request_body)
    response_body.to_json
  end

  def handle_request(sake_request)
  	request_type = sake_request["request"]["type"]
  	if request_type == "LaunchRequest"
  		LaunchHandler.handle(sake_request)
  	elsif request_type == "IntentRequest"
  		IntentHandler.handle(sake_request)
  	elsif request_type == "SessionEndedRequest"
  		SesssionEndedHandler.handle(sake_request)
  	end
  end
end
