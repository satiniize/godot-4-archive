class_name Bioweapon

extends Object

var actiontype = 0x00

enum Type{
	HOMOZYGOUS_RECESSIVE, 
	HETEROZYGOUS, 
	HOMOZYGOUS_DOMINANT 
}

enum Phenotype{
	SHOOTING_TYPE,
	PELLET_SIZE,
	PELLET_PRIMING_RATE,
	RESERVE_PELLET_CAPACITY,
	PRIMED_PELLET_CAPACITY,
	REFRACTORY_PERIOD,
	PELLET_CLUSTERING,
	BARREL_LENGTH,
	ERGONOMICS
}

enum ShootingType{
	SINGLE_FIRE,
	SEMI_AUTO,
	FULL_AUTO
}

var phenotype: Dictionary = {
	Phenotype.SHOOTING_TYPE		: ShootingType.SINGLE_FIRE, #enum
	Phenotype.PELLET_SIZE				: 0.0, #float
	Phenotype.PELLET_PRIMING_RATE		: 0.0, #float
	Phenotype.RESERVE_PELLET_CAPACITY	: 0, #int
	Phenotype.PRIMED_PELLET_CAPACITY		: 0, #int
	Phenotype.REFRACTORY_PERIOD			: 0.0, #float
	Phenotype.PELLET_CLUSTERING			: 0, #int
	Phenotype.BARREL_LENGTH			: 0.0, #float
	Phenotype.ERGONOMICS			: 0.0 #float
}

var genotype: Dictionary = {
	Phenotype.SHOOTING_TYPE				: [],
	Phenotype.PELLET_SIZE				: [],
	Phenotype.PELLET_PRIMING_RATE		: [],
	Phenotype.RESERVE_PELLET_CAPACITY	: [],
	Phenotype.PRIMED_PELLET_CAPACITY	: [],
	Phenotype.REFRACTORY_PERIOD			: [],
	Phenotype.PELLET_CLUSTERING			: [],
	Phenotype.BARREL_LENGTH				: [],
	Phenotype.ERGONOMICS				: []
}

var polygenic_complexity: Dictionary = {
	Phenotype.SHOOTING_TYPE				: 1,
	Phenotype.PELLET_SIZE				: 10,
	Phenotype.PELLET_PRIMING_RATE		: 4,
	Phenotype.RESERVE_PELLET_CAPACITY	: 10,
	Phenotype.PRIMED_PELLET_CAPACITY	: 4,
	Phenotype.REFRACTORY_PERIOD			: 4,
	Phenotype.PELLET_CLUSTERING			: 4,
	Phenotype.BARREL_LENGTH				: 5,
	Phenotype.ERGONOMICS				: 5
}

var allelic_contribution: Dictionary = {
	Phenotype.PELLET_SIZE				: [ #20 - 100
		2,
		10,
		20
	], #float
	Phenotype.PELLET_PRIMING_RATE		: [
		1.0,
		0.4,
		0.1
	], #float
	Phenotype.RESERVE_PELLET_CAPACITY	: [
		2,
		8,
		20
	], #int
	Phenotype.PRIMED_PELLET_CAPACITY		: [
		2,
		8,
		20
	], #int
	Phenotype.REFRACTORY_PERIOD			: [
		0.5,
		0.2,
		0.05
	], #float
	Phenotype.PELLET_CLUSTERING			: [
		1,
		2,
		4
	], #int
	Phenotype.BARREL_LENGTH			: [
		1,
		5,
		10
	], #float # 5cm - 50cm
	Phenotype.ERGONOMICS : [
		0.0,
		0.0,
		0.0
	] #float #
}


#TODO:	Convert allele pair object oriented programming to functional because
#		this shit is honestly retarded


func _init() -> void:
	#Enums =/= integers somehow
	for _trait in Phenotype.values():
		for i in range(polygenic_complexity[_trait]):
			genotype[_trait].push_back(AllelePair.new())
	
	bake_weapon_specs()
	
	print(phenotype)


func bake_weapon_specs():
	for _trait in Phenotype.values():
		if _trait == Phenotype.SHOOTING_TYPE:
			match genotype[Phenotype.SHOOTING_TYPE][0].get_type():
				AllelePair.Type.HOMOZYGOUS_RECESSIVE:
					phenotype[Phenotype.SHOOTING_TYPE] = ShootingType.SINGLE_FIRE
				AllelePair.Type.HETEROZYGOUS:
					phenotype[Phenotype.SHOOTING_TYPE] = ShootingType.SEMI_AUTO
				AllelePair.Type.HOMOZYGOUS_DOMINANT:
					phenotype[Phenotype.SHOOTING_TYPE] = ShootingType.FULL_AUTO
		else:
			for allele_pair in genotype[_trait]:
				phenotype[_trait] += allelic_contribution[_trait][allele_pair.type]


#Shooting Type -> Single Fire, Semi Auto, Full Auto	
#Pellet Size					Increase Damage									
#Pellet Priming Speed		0.4s-4s
	#> 4 Genes
	#Homore contributes 1.0
	#Hetero contributes 0.4
	#Homodo allele contributes 0.1
#Reserve Pellet Capacity		20-200
	#> 10 Genes
	#Homore contributes 2
	#Hetero contributes 8?
	#Homodo allele contributes 20
#Primed Pellet Capacity			8-80
	#> 4 Genes
	#Homore contributes 2
	#Hetero contributes 8?
	#Homodo contributes 20
#Refractory Period 				0.2s-2s								
	#> 4 Genes
	#Homore contributes 0.05
	#Hetero contributes 0.2
	#Homodo allele contributes 0.5
#Clustering						4-16 HMMMMM (might change to rounding system )
	#> 4 Genes
	#Homore contributes 1
	#Hetero contributes 2
	#Homodo allele contributes 4
#Barrel Length					Increase Accuracy									
#Ergonomics						Reduce Recoil									
#Color?							Linked to Other Genes				

#Use for loops for law of segregation
