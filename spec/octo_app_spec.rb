require_relative "spec_helper"
require_relative "../octo_app.rb"

def app
  OctoApp
end

describe OctoApp do
  it "responds with a welcome message" do
    get '/'

    last_response.body.must_include 'Welcome to the Sinatra Template!'
  end
end
