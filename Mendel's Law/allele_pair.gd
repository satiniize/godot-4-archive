class_name AllelePair

extends Object

var gene_id: int = 0

enum Type{
	HOMOZYGOUS_RECESSIVE, 
	HETEROZYGOUS, 
	HOMOZYGOUS_DOMINANT 
}

var type: Type

#0 -> 0, 1, 3 homore
#1 -> 1, 2, 4 hetero
#3 -> 3, 4, 6 homodo

#3 being the size of Type
func _init(value: Type=Type.values()[randi() % Type.size()]) -> void:
	type = value


func set_type(value: Type) -> void:
	type = value


func get_type() -> Type:
	return type


func type_to_id() -> int:
	var conversion: Dictionary = {
		Type.HOMOZYGOUS_RECESSIVE : 0,
		Type.HETEROZYGOUS : 1,
		Type.HOMOZYGOUS_DOMINANT : 3
	}
	return conversion[get_type()]


func cross(with: AllelePair) -> AllelePair:
	var sum: int = type_to_id() + with.type_to_id()
	var child_pair: AllelePair = AllelePair.new()
	match sum:
		0: # aa x aa
			child_pair.set_type(Type.HOMOZYGOUS_RECESSIVE) #always returns aa
		1: # aa x Aa 
			var random_int: int = randi() % 2
			if random_int == 0: #Aa or aa
				child_pair.set_type(Type.HETEROZYGOUS)
			else:
				child_pair.set_type(Type.HOMOZYGOUS_RECESSIVE)
		2: # Aa x Aa
			var random_int: int = randi() % 4
			if random_int == 0: #AA, Aa, or aa, 1 : 2 : 1
				child_pair.set_type(Type.HOMOZYGOUS_DOMINANT)
			elif random_int == 1:
				child_pair.set_type(Type.HOMOZYGOUS_RECESSIVE)
			else:
				child_pair.set_type(Type.HETEROZYGOUS)
		3: # aa x AA
			child_pair.set_type(Type.HETEROZYGOUS) #always returns Aa
		4: # Aa x AA
			var random_int: int = randi() % 2
			if random_int == 0: #AA or Aa
				child_pair.set_type(Type.HOMOZYGOUS_DOMINANT)
			else:
				child_pair.set_type(Type.HETEROZYGOUS)
		6: # AA x AA
			child_pair.set_type(Type.HOMOZYGOUS_DOMINANT) #always returns AA
	return child_pair
