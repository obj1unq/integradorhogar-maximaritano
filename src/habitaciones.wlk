
//Nota: 8 (ocho)

//test: no andan porque tiene problemas al instanciar los objetos (usa una variable que aun no está definida)
// Eso no se arregla simplemente modificando el orden, porque hay referencias cruzadas. 
//La relación bidireccional debe establecerse con un mensaje
// 1.1) MB-
// 1.2) MB
// 2.1) MB -
// 2.3) B En los test no se usa como espera el código (enviando un mensaje adicional incorrectamente. No maneja correctamente el caso en que la persona no esté en ninguna habitacion
// 3.1) B+
// 3.2) MB-
//3.3) B Pasa la familia por parametro cuando espera una casa
//3.4) R El modelo presenta problemas de relaciones y hay objetos que no entienden los mensajes enviados.



class Habitacion{
	
	//TODO: Variable innecesaria, de hecho está mal que se pueda cambiar. Es algo fijo
	var property confort = 10
	var property ocupantes = #{}
	
	method nivelDeConfort(persona){
		return self.confort() + self.puntosAdicionalesConfort(persona)
	}
	
	method puntosAdicionalesConfort(persona)
	
	method estaVacia(){
		//TODO: usar isEmpty()
		return self.ocupantes().size() == 0
	}
	
	method puedeEntrar(persona){
		return self.estaVacia()
	}
	
	method entrar(persona){
		self.validarEntrada(persona) 
		self.ocupantes().add(persona)
		//TODO: delegar mejor: persona.abandonarHabitacion()
		//TODO: Y si la persona no está en ninguna habitacion actualmente esto se rompe
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
	
	//TODO: ojo que pierde el comportamiento de la superclase, en este caso justo no es grave 
	//porque siempre puede entrar independientemente de lo que determine la clase padre
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
		//TODO: pierde el comporatmiento de la superclase, tampoco es importante porque este código
		//funciona independientemente de lo que diga la superclase.
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

//TODO: Las Clases son siempre en singular
class Obsesivos inherits Persona{
	//TODO: codigo duplicado: todas las personas necesitan poder entrar a una habitacion, ponerlo en la superclase
	override method estaAGusto(){
		return self.puedeEntrarAAlgunaHabitacion() and casa.habitaciones().all({habitacion=>habitacion.ocupantes().size()<=2})
	}
}

class Golozas inherits Persona{
	override method estaAGusto(){
		//TODO: La casa no entiende el mensaje personas, y aunque lo entienda no serviría, porque se trata de la familia
		//TODO y puede haber personas de la familia que no estén en la casa
		return self.puedeEntrarAAlgunaHabitacion() and casa.personas().any({persona=>persona.esCocinera()})
	}
}

class Sencillas inherits Persona{
	override method estaAGusto(){
		//TODO: La casa no entiende el mensaje personas, y aunque lo entienda no serviría, porque se trata de la familia
		//TODO y puede haber personas de la familia que no estén en la casa
		return self.puedeEntrarAAlgunaHabitacion() and casa.habitaciones().size()>casa.personas().size()
	}
}

class Casa{
	var property habitaciones= #{}
	
	method habitacionesOcupadas(){
		//TODO: delegar mejor: habitación.vacia()
		return self.habitaciones().filter({habitacion => habitacion.ocupantes().size() > 0})
	}
	
	method responsablesDeLaCasa(){
		//TODO: convendría hacer un asSet luego del map para devolver un conjunto
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
		//espera una casa por paremtro pero le estas pasando una familia
		return personas.sum({persona=>persona.nivelDeConfort(self)})
}
	
	method cantidadMiembros(){
		return self.personas().size()
	}
	
	method estaAGusto(){
		return self.nivelConfortPromedio()>40 and self.personas().all({persona=> persona.estaAGusto()})
	}
	
}