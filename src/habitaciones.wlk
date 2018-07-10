class Habitacion{
	var property confort = 10
	var property ocupantes = #{}
	
	method nivelDeConfort(persona){
		return self.confort() + self.puntosAdicionalesConfort(persona)
	}
	
	method puntosAdicionalesConfort(persona)
	
	method estaVacia(){
		return self.ocupantes().size() == 0
	}
	
	method puedeEntrar(persona){
		return self.estaVacia()
	}
	
	method entrar(persona){
		self.validarEntrada(persona) 
		self.ocupantes().add(persona)
		persona.habitacion().ocupantes().remove(persona)
		persona.nuevaHabitacion(self)
		
		//else 
		//{self.error("La persona no puede ingresar")}
	}
	
	method validarEntrada(persona){
		if (!self.puedeEntrar(persona)){
			self.error("No puede ingresar")
		}
	}
	
	method ocupanteMasViejo(){
		return self.ocupantes().max({ocupante => ocupante.edad()})
	}
}

class UsoGeneral inherits Habitacion{
	override method puntosAdicionalesConfort(persona) = 0
	
	override method puedeEntrar(persona) = true
	
	override method entrar(persona){
		self.ocupantes().add(persona)
	}
}

class Banio inherits Habitacion{
	override method puntosAdicionalesConfort(persona){
		return if (persona.esNinioMenorDe5()) 2
				else 4
	}
	
	override method puedeEntrar(_persona){
		return super(_persona) or 
		self.ocupantes().any({persona => persona.esNinioMenorDe5()})
	}
}

class Dormitorio inherits Habitacion{
	var property duenios = #{}
	
	method esDuenio(persona){
		return self.duenios().contains(persona)
	}
	
	method cantidadDuenios(){
	return	self.duenios().size()
	}
	
	override method puntosAdicionalesConfort(persona){
		return if (!self.esDuenio(persona)) 0
				else 10/self.cantidadDuenios()
	}
	
	override method puedeEntrar(persona){
		return super(persona) or self.esDuenio(persona) or 
		self.estanPresentesTodosLosDuenios()
	}
	
	method estanPresentesTodosLosDuenios(){
		return self.duenios().all({duenio => self.estaEnLaHabitacion(duenio)})
	}
	
	method estaEnLaHabitacion(persona){
		return self.ocupantes().contains(persona)
	}
}

class Cocina inherits Habitacion{
	var property mtsCuadrados
		
	override method puntosAdicionalesConfort(persona){
	return if (persona.esCocinera()) porcentajeCocina.porcentaje() * mtsCuadrados
		else 0	
	}
	
	override method puedeEntrar(persona){
		return if (persona.esCocinera()) self.noHayCocinero()
		else true
	}
	
	method noHayCocinero(){
		return self.ocupantes().all({persona => !persona.esCocinera()})
	}
}

object porcentajeCocina{
	var valor = 0.1
	
	method cambiarValor(nuevoValor){
	valor = nuevoValor
	}
	
	method porcentaje() = valor
}

class Persona{
	var property edad
	var property esCocinera 
	var property habitacion = null
	var property casa 
	
	method nuevaHabitacion(_habitacion){
		habitacion = _habitacion
	}
	
	method esNinioMenorDe5(){
		return self.edad()<=4
	}
	
	method aprenderCocina(){
		esCocinera = true
	}
	
	method nivelConfort(_casa){
		return _casa.habitaciones().sum({_habitacion => _habitacion.nivelDeConfort(self)})
	}
	
	method estaAGusto()
	
	method puedeEntrarAAlgunaHabitacion(){
		return casa.habitaciones().any({_habitacion=> _habitacion.puedeEntrar(self)})
}
}

class Obsesivos inherits Persona{
	override method estaAGusto(){
		return self.puedeEntrarAAlgunaHabitacion() and casa.habitaciones().all({habitacion=>habitacion.ocupantes().size()<=2})
	}
}

class Golozas inherits Persona{
	override method estaAGusto(){
		return self.puedeEntrarAAlgunaHabitacion() and casa.personas().any({persona=>persona.esCocinera()})
	}
}

class Sencillas inherits Persona{
	override method estaAGusto(){
		return self.puedeEntrarAAlgunaHabitacion() and casa.habitaciones().size()>casa.personas().size()
	}
}

class Casa{
	var property habitaciones= #{}
	
	method habitacionesOcupadas(){
		return self.habitaciones().filter({habitacion => habitacion.ocupantes().size() > 0})
	}
	
	method responsablesDeLaCasa(){
		return self.habitacionesOcupadas().map({habitacion => habitacion.ocupanteMasViejo()})
	}
	
}

class Familia{
	var property personas = #{}
	var property casa = null
	
	method nivelConfortPromedio(){
		return self.nivelDeConfort() / self.cantidadMiembros()
	}
	
	method nivelDeConfort(){
		return personas.sum({persona=>persona.nivelDeConfort(self)})
}
	
	method cantidadMiembros(){
		return self.personas().size()
	}
	
	method estaAGusto(){
		return self.nivelConfortPromedio()>40 and self.personas().all({persona=> persona.estaAGusto()})
	}
	
}