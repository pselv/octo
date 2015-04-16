class CookBook < Sinatra::Base

  get "/launch" do
  	content_type :json
    greeting = {text: "Hello, what would you like to do?"}
    greeting.to_json
  end
  
end
