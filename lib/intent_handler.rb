class IntentHandler
	def self.handle(saka_request)
		session_attrs = saka_request["session"]["attributes"]
		intent_request = saka_request["request"]
		intent = intent_request["intent"]
		if intent["name"] == "CookRecipe"
			output, recipe_id =  cook_recipe(intent["slots"])
			build_response_for_cook_recipe(saka_request, output, recipe_id)
		elsif %w(Ingredients Equipments Instructions).include?(intent["name"])
			walk_state = intent["name"]
			output_text, next_seq_no = walk(session_attrs['recipeId'], walk_state, session_attrs[walk_state])
			build_response_for_walk_state(session_attrs, output_text, walk_state, next_seq_no)
		else
			handle_walk_to_state(intent, session_attrs)
		end
	end

	def self.handle_walk_to_state(intent, session_attrs)
		walk_state = session_attrs['walk_state']
		if walk_state == nil
			output_text = "I can run through ingredients, equipments needed and cooking instructions, tell me what would you like to do next."
			build_response_for_walk_state_when_nil(session_attrs, output_text)
		elsif intent["name"] == 'next'			
			output_text, next_seq_no = walk(session_attrs['recipeId'], walk_state, session_attrs[walk_state])
		elsif intent['name'] == 'repeat'			
			output_text, next_seq_no = walk(session_attrs['recipeId'], walk_state, session_attrs[walk_state]-1)
		elsif intent['name'] == 'startover'			
			output_text, next_seq_no = walk(session_attrs['recipeId'], walk_state, 1)
			# TODO boundary cases
		end
		build_response_for_walk_state(session_attrs, output_text, walk_state, next_seq_no)
	end

# Cook Recipe
	def self.cook_recipe(cook_recipe_slots)
		recipe_name = cook_recipe_slots["RecipeName"]["value"]
		recipe = Recipe.find_by(name: recipe_name) rescue nil
		if recipe != nil
			["#{recipe.name} recipe loaded, I can run through ingredients, equipments needed and cooking instructions, tell me what would you like to do next.", recipe.id.to_s]
		else 
			["Sorry, I could not find #{recipe_name} recipe, please provide a differnt recipe.", nil]
		end
	end


	def self.walk(recipe_id, walk_state, seq_no)
		if seq_no == nil
			output_text = "There are no more #{walk_state}, would you like to start over #{walk_state} or go back."
			next_seq_no = nil
		else
			detail, next_seq_no = current_walk_state(recipe_id, walk_state, seq_no)
			options = next_seq_no == nil ?  "we are done with #{walk_state}. you can say repeat or start over." : "you can say next, repeat or start over"
			output_text = "#{detail}. #{options}"
		end
		[output_text, next_seq_no]
	end

	def self.current_walk_state(recipe_id, walk_state, seq_no)
		recipe = Recipe.find(recipe_id) rescue nil
		items = recipe.send(walk_state.downcase.to_sym).select{ |a| a.sequence_number >= seq_no}.sort{ |a, b| a.sequence_number <=> b.sequence_number}
		items.size == 0 ? [nil, nil] : [items.first.description, items.size == 1 ? nil : items.first.sequence_number + 1]
	end

	def self.build_response_for_cook_recipe(saka_request, output_text, recipe_id)
		response_body = {"response" => {"outputSpeech" => {"type" => "PlainText", "text" => output_text}, "shouldEndSession" => false}}
    	response_body["version"] = saka_request["version"]
    	session_attrs = (saka_request['session'] || {})['attributes'] || {}
    	if recipe_id
	    	session_attrs["recipeId"] = recipe_id 
	    	session_attrs["Ingredients"] = 1
	    	session_attrs["Equipments"] = 1
	    	session_attrs["Instructions"] = 1
	    end
    	response_body["sessionAttributes"] = session_attrs
    	response_body
	end

	def self.build_response_for_walk_state(session_attrs, output_text, walk_state, next_seq_no)
		response_body = {"response" => {"outputSpeech" => {"type" => "PlainText", "text" => output_text}, "shouldEndSession" => false}}
    	response_body["version"] = "1.0"
    	response_body["sessionAttributes"] = session_attrs
    	response_body["sessionAttributes"]["walk_state"] = walk_state
    	response_body["sessionAttributes"][walk_state] = next_seq_no
    	response_body
	end

	def self.build_response_for_walk_state_when_nil(session_attrs, output_text)
		response_body = {"response" => {"outputSpeech" => {"type" => "PlainText", "text" => output_text}, "shouldEndSession" => false}}
    	response_body["version"] = "1.0"
    	response_body["sessionAttributes"] = session_attrs
    	response_body
	end
end