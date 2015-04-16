class Recipe
	include Mongoid::Document
	field :name, type: String
	field :author, type: String
	embeds_one :properties, class_name: "Properties"
	embeds_many :equipments, class_name: "Equipment"
	embeds_many :ingredients, class_name: "Ingredient"
	embeds_many :instructions, class_name: "Instruction"
end

class Ingredient
	include Mongoid::Document
	field :sequence_number, type: Integer
	field :description, type: String
end

class Equipment
	include Mongoid::Document
	field :sequence_number, type: Integer
	field :description, type: String
end

class Instruction
	include Mongoid::Document
	field :sequence_number, type: Integer
	field :description, type: String
end

class Properties
	include Mongoid::Document
	field :cuisine, type: String
	field :prferredMeal, type: String
	field :calories, type: Integer
	field :preparationTimeInMins, type: Integer
	field :cookingTimeInMins, type: Integer
	field :servingSize, type: Integer
end
