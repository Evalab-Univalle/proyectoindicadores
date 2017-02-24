#!/usr/bin/env ruby
# encoding: utf-8
# File: indicadores.rb
Copyright = 
"Ángel García Baños <angel.garcia@correounivalle.edu.co>\n" +
"Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>\n" +
"Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>\n" +
"Institution: EISC, Universidad del Valle, Colombia\n" +
"Creation date: 2015-12-15\n" +
"Last modification date: 2017-02-24\n" +
"License: GNU-GPL"
Version = "0.8"
Description = "To verify linearised indicators versus its Pareto front. If FILEs are provided (tab separated CSV format) they must contain real universities with its indicators and weigths (one FILE is processed at a time). Otherwise, a set of random universities will be generated"
Dependences = "Nothing"
#--------------------------------------------------
# VERSIONES
# 0.8 Se agregan los máximos y mínimos para cada experimento
# 0.7 Corrección de un error en el orden de salida de los promedios y desviación (falsos positivos y falsos negativos). La semilla de los números pseudoaleatorios ahora es el tiempo del PC
# 0.6 Nuevo experimento: se cambian al azar las ponderaciones para ver cuanto cambian las posiciones de las universidades en el ranking
# 0.5 Refactorización. Se ponen dos constructores para Punto.
# 0.4 Se añade la posibilidad de leer un archivo con universidades e indicadores linearizados, en vez de usar puntos aleatorios. Se añade también la posibilidad de cambiar al azar los pesos de los indicadores, para medir como influyen en los rankings.
# 0.3 Se eliminan las funciones minimizarRanking, maximizarRanking e invertirRanking, porque son complicadas
#     y no aportan mucho. Se eliminan bugs en la impresión de los resultados finales.
# 0.2 Refactorizada la clase punto. Ahora hereda de Array.
# 0.1 Inicial
#--------------------------------------------------
# Para ayudar a depurar:
def dd(n, a)
  p "[#{n}] #{a.inspect}"
  p "===="
end
#--------------------------------------------------
require 'optparse'
class Argumentos < Hash
  def initialize(args)
    super()
    self[:times] = 100
    self[:numUniversidades]=100
    self[:numFactoresAEvaluar]=50
    options = OptionParser.new do |option|
      option.banner = "Use: #$0 [options] [FILE...]\n\n" + Description + "\n\n" + Copyright + "\nVersion: " + Version + "\nOptions:\n" + "Dependences:\n" + Dependences

      option.on('-c', '--csv', 'output in csv format') do
        self[:csv] = true
      end
      option.on('-t', '--todo', 'out all experiments for each combination') do
        self[:todo] = true
      end

      option.on('-m', '--minmax', 'output in CSV format with maximum and minimum') do
        self[:minmax] = true
      end

      option.on('-t=ARG', '--times=ARG', 'repeat the experiment this number of times') do |arg|
        self[:times] = arg.to_i
      end

      option.on('-u=ARG', '--universities=ARG', 'number of universities') do |arg|
        self[:numUniversidades] = arg.to_i
      end

      option.on('-i=ARG', '--indicators=ARG', 'number of indicators (factors) to evaluate') do |arg|
        self[:numFactoresAEvaluar] = arg.to_i
      end

      option.on('-r', '--rand', 'it generates random points to be clasified, ignoring the optional FILEs. If FILEs do not exist, that is the default behavior') do
        self[:rand] = true
      end
      option.on('-v', '--version', 'shows version and quits') do
        puts Version
        exit
      end
      option.on_tail('-h', '--help', 'shows this help and quits') do
        puts option
        exit
      end
    end
    options.parse!(args)
  end
end

#--------------------------------------------------
# Un punto es un vector de indicadores (valores entre 0 y 1). Por ejemplo, una universidad con sus indicadores de publicaciones, docencia, investigación, etc. O un estudiante con cada una de las calificaciones de las asignaturas que ha cursado. Etc. Cuanto mayor es el valor del indicador, mejor.
class Punto < Array
  # Crea el punto con el número de dimensiones especificado. En cada dimensión se pone un indicador generado al azar entre 0 y un valorMaximo (por defecto, 1).
  # El valorMinimo y el valorMaximo sólo tienen importancia si se van a crear puntos con valores al azar. En los demás casos se ignoran.
  def initialize(nuevosValores, valorMinimo=0.0, valorMaximo=1.0)
    @numeroDimensiones, @valorMinimo, @valorMaximo = nuevosValores.size, valorMinimo, valorMaximo
    self.replace nuevosValores
  end
  
  # Función de clase, que simula ser un constructor de un punto con indicadores aleatorios. Recibe el número de dimensiones, el valorMinimo (por defecto, 0.0)
  # y el valorMaximo (por defecto 1.0) y crea el punto generando al azar todos los indicadores entre esos dos valores. Retorna el punto creado.
  def self.new_rand(numeroDimensiones, valorMinimo=0.0, valorMaximo=1.0)
    valores = []
    numeroDimensiones.times { valores << rand(valorMinimo..valorMaximo) }
    self.new(valores, valorMinimo, valorMaximo)
  end
  
  # Función de clase, que simula ser un constructor de un punto con indicadores dados. Recibe los valores de los indicadores, el valorMinimo (por defecto, 0.0). Es un alias del constructor de objetos.
  # y el valorMaximo (por defecto 1.0) y crea el punto con esos valores. Retorna el punto creado.
  def self.new_fromValues(nuevosValores, valorMinimo=0.0, valorMaximo=1.0)
    self.new(nuevosValores, valorMinimo, valorMaximo)
  end
   
  # Verifica si el punto está dominado por otro punto, es decir, si cada uno de los indicadores del otro punto es mejor (mayor o igual). 
  # Retorna true si está dominado por el otro punto, y false en caso contrario. Pero si los dos puntos son idénticos, retorna false.
  def dominado_por?(otroPunto)
    distintos = false
    self.zip(otroPunto).each do |d1, d2| 
      return false if d2 < d1
      distintos = true if d2 != d1
    end
    distintos  # En todos los casos en que se cumple que d2 >= d1
  end

  # Verifica si el punto no está dominado por ningún otro, de un vector de puntos que recibe como entrada.
  # Retorna true si no está dominado por ninguno y false si está dominado por al menos uno.
  def dominado_por_ningun?(puntos)
    puntos.each { |punto| return false if dominado_por?(punto) }
    return true
  end
  
  #Calcula y retorna el promedio de todos los indicadores.
  def promedio
    (self.inject(0.0) { |suma, x| suma+x }) / @numeroDimensiones.to_f
  end
  
  # Calcula y retorna el promedio ponderado de todos los indicadores, a partir de un vector de pesos que recibe como entrada.
  def ponderado(pesos)
    self.zip(pesos).inject(0.0) { |suma, coordenada_y_peso| suma+coordenada_y_peso[0]*coordenada_y_peso[1] }
  end
  
  # Cambia un indicador del punto. Esta función solo sirve para facilitar el test de esta clase.
  def cambiarIndicador(cualIndicador, nuevoValor)
    self[cualIndicador] = nuevoValor
  end
  
  # Copia profunda.
  def clone
    Punto.new_fromValues(self, @valorMinimo, @valorMaximo)
  end
end



#--------------------------------------------------
# Un experimento consiste en un conjunto de puntos. Los puntos, con un número determinado de dimensiones, se pueden añadir uno a uno o se pueden generar al azar. 
# Luego se puede comparar la frontera de Pareto de ese conjunto de puntos con el resultado de buscar el óptimo linealizando los indicadores.
class Experimento < Array
  # No hay que hacer nada especial.
  def initialize()
  end
  
  # Añadir un número de puntos, generados al azar, con un cierto número de dimensiones.
  def añadirPuntosAlAzar(numeroPuntos, numeroDimensiones)
    @numeroDimensiones = numeroDimensiones
    numeroPuntos.times { añadirPunto(Punto.new_rand(numeroDimensiones)) }
  end
  
  # Añade un punto al conjunto.
  def añadirPunto(punto)
    self << punto
  end
  
  # Lee un archivo de entrada conteniendo universidades reales con sus indicadores. Las columnas deben ir en este orden:
  #    n,University,Economy,Overall
  # y luego debe haber más columnas con los indicadores que se están analizando
  # Retorna el número de universidades y el número de indicadores
  def añadirPuntos(archivoEntrada)
    separador = "\t"
    cabecera = "n#{separador}University#{separador}Economy#{separador}Overall#{separador}"
    cabecera_size = cabecera.split(separador).size
    numLinea = 1
    indicadores_size = 0
    File.open(archivoEntrada) do |f|
      primeraLinea = f.gets
      raise ArgumentError, "La primera línea del archivo #{archivoEntrada} tiene un formato desconocido. Debería ser #{cabecera}..." if primeraLinea.index(cabecera) != 0
      primeraLinea.gsub!(/^#{cabecera}/, "")
      nombresIndicadores = primeraLinea.split(separador)
      indicadores_size = nombresIndicadores.size
      raise ArgumentError, "A la primera línea del archivo #{archivoEntrada} le faltan los nombres de los indicadores después de: #{cabecera}..." if indicadores_size == 0
      numeroColumnas = cabecera_size + indicadores_size
      while(linea = f.gets)
        numLinea += 1
        valores = linea.split(separador).collect { |v| v.to_f }
#        raise ArgumentError, "En el archivo #{archivoEntrada}, la línea #{numLinea} #{linea} debería tener #{numeroColumnas} columnas, pero sólo tiene #{valores.size}" if valores.size != columnas  # Este mensaje es dificil de verificar en BDD. Por eso opté por la siguiente línea:
        raise ArgumentError, "En el archivo #{archivoEntrada}, la línea #{numLinea} tiene un número de columnas distinto a la primera línea del archivo" if valores.size != numeroColumnas
        añadirPunto(Punto.new_fromValues(valores[cabecera_size,indicadores_size]))
      end
    end
    return numLinea-1, indicadores_size
  end
  
  # Ejecuta el experimento de comparar óptimos de Pareto contra óptimos lineales. Retorna un hash con los resultados.
  # Para ello:
  # - Crea el conjunto de puntos. Cada punto es un vector de indicadores. Y el promedio de todos los indicadores va a darnos la bondad de esepunto según el algoritmo de linealizar.
  # - Calcula la frontera de Pareto de ese conjunto de puntos.
  # - Ordena los puntos en un ranking de mayor a menor (es decir, linealiza todas las funciones en una única), usando para ello su promedio de indicadores. 
  # - Si el primer punto del ranking pertenece a la frontera de Pareto, entonces el algoritmo de linealizar acertoConElPrimero y se anota ello en sus resultados.
  # - Si los "i" primeros del ranking pertenecen a la frontera de Pareto, entonces el algoritmo de linealizar acertó en "i" casos, y se anota ello en sus resultados. 
  # - Se calculan los falsos positivos (están bien situados en el ranking, pero no forman parte de la frontera de Pareto) y los falsos negativos (están en la frontera de Pareto, pero se encuentran mal situados en el ranking) y se guarda cuantos hay de cada uno en los resultados. 
  # - Se generan al azar las ponderaciones, se evalúan los nuevos rankings y se cuenta cual es el mayor desplazamiento de un punto dentro del ranking, que se guarda en los resultados.
  def ejecutarTodasLasPruebas
    resultado = Hash.new(0) # Por default, los valores inexistentes son 0
    fronteraPareto = calcularFronteraPareto()
    ranking = self.sort_by { |x| x.promedio }.reverse
    resultado[:acertoConElPrimero] = (fronteraPareto.include?(ranking[0]) ? 1 : 0)
    aciertos, positivos, negativos = aciertosYFallos(fronteraPareto, ranking)
    resultado[:aciertos], resultado[:falsosPositivos], resultado[:falsosNegativos] = aciertos.length, positivos.length, negativos.length
    mayorDesplazamiento = cambiarPonderaciones(ranking)
    resultado[:mayorDesplazamiento] = mayorDesplazamiento
    resultado
  end  
 
  # Retorna los aciertos, los falsos positivos y los falsos negativos.
  def aciertosYFallos(fronteraPareto, ranking)
    voyAcertando = true
    aciertos, falsosPositivos, falsosNegativos = [], [], []
    ranking.each do |item|
      if (fronteraPareto.include?(item) or fronteraPareto.empty?)
        if voyAcertando
          aciertos << item
        else
          if fronteraPareto.include?(item)
            falsosNegativos << item
          else
            falsosPositivos << item
          end
        end
        fronteraPareto.delete(item)
        voyAcertando = true if fronteraPareto.empty?
      else
        falsosPositivos << item
        voyAcertando = false
      end
    end
    return aciertos, falsosPositivos, falsosNegativos
  end
  
  
  # Retorna la frontera de Pareto del conjunto de puntos, que está formada por los puntos no dominados por ningún otro.
  def calcularFronteraPareto
    resultado = []
    self.each do |punto|
      resultado << punto if punto.dominado_por_ningun?(self - punto)
    end
    resultado
  end
  
  # Cambia al azar las ponderaciones y busca cual es el punto que sufrió el mayor desplazamiento dentro del ranking. Retorna ese mayor desplazamiento.
  def cambiarPonderaciones(rankingViejo)
    ponderaciones = []
    total = 0
    while total < 1e-3 # Para evitar dividir por 0 en la siguiente instrucción, aunque ello sea altamente improbable
      ponderaciones.clear
      @numeroDimensiones.times { ponderaciones << rand(0.0..1.0) }
      total = ponderaciones.inject(0) { |suma, item| suma+item }
    end
    ponderaciones.collect! { |item| item/total } # Se normalizan para que el total sume 1
    rankingNuevo = self.sort_by { |x| x.ponderado(ponderaciones) }.reverse
    diferenciaMayor(rankingNuevo, rankingViejo)
  end
  
  # Busca el elemento que más haya cambiado entre dos rankings y retorna la diferencia entre ambas posiciones en valor absoluto.
  def diferenciaMayor(rankingNuevo, rankingViejo)
    diferencias = {}
    rankingNuevo.each_with_index { |punto, indice| diferencias[punto] = indice }
    rankingViejo.each_with_index { |punto, indice| diferencias[punto] -= indice }
    diferencias.max_by{ |punto| punto[1].abs }[1].abs
  end
end


#--------------------------------------------------
# Se repite el experimento un número determinado de veces, para generar estadísticas de los resultados.
class Experimentos
  def initialize(numeroVeces, numeroPuntos, numeroDimensiones, csv, imprimirTodo, minmax, archivoEntrada)
    @numeroVeces, @numeroPuntos, @numeroDimensiones, @csv, @imprimirTodo, @minmax, @archivoEntrada = numeroVeces, numeroPuntos, numeroDimensiones, csv, imprimirTodo, minmax, archivoEntrada
  end
  
	def ejecutar
		@resultados = []
		@numeroVeces.times do
		experimento = Experimento.new
		  if @archivoEntrada
			@numeroPuntos, @numeroDimensiones = experimento.añadirPuntos(@archivoEntrada)
		  else
			experimento.añadirPuntosAlAzar(@numeroPuntos, @numeroDimensiones)
		  end
		  @resultados << experimento.ejecutarTodasLasPruebas
		end
	end



	def imprimir

		nv = @numeroVeces.to_f
		np = @numeroPuntos.to_f
		promedios = @resultados.inject([0.0,0.0,0.0,0.0,0.0,0.0]) do |acumulado, resultado| 
		  [ 
			acumulado[0]+resultado[:acertoConElPrimero],
			acumulado[1]+resultado[:aciertos],
			acumulado[2]+resultado[:falsosPositivos],
			acumulado[3]+resultado[:falsosNegativos],
			acumulado[4]+resultado[:mayorDesplazamiento],
			[acumulado[5],resultado[:mayorDesplazamiento]].max
		  ] 
		end

		promedios.collect! { |x| x/(nv*np) }
		promedios[0] *= np

		# Se saca la desviación típica de cada resultado:
		desviaciones = @resultados.inject([0.0,0.0,0.0,0.0,0.0,0.0]) do |acumulado, resultado| 
		  [ 
			acumulado[0]+(resultado[:acertoConElPrimero]-promedios[0])**2,
			acumulado[1]+(resultado[:aciertos]-promedios[1])**2,
			acumulado[2]+(resultado[:falsosPositivos]-promedios[2])**2,
			acumulado[3]+(resultado[:falsosNegativos]-promedios[3])**2,
			acumulado[4]+(resultado[:mayorDesplazamiento]-promedios[4])**2,
			0.0 # No se pueden calcular desviaciones típicas sobre valores máximos, sino solo sobre promedios
		  ]
		end

		promedios.collect! { |x| x*100.0 }
		desviaciones.collect! { |x| Math.sqrt(x*100.0/(nv*np)) }
		desviaciones[0] *= np

		if @minmax
			#Sacamos el maximo y minimo del experimento
			@maximos = @resultados.inject([0.0,0.0,0.0,0.0]) do |acumulado, resultado| 
			[ 
				[acumulado[0],resultado[:acertoConElPrimero]].max,
				[acumulado[1],resultado[:aciertos]].max,
				[acumulado[2],resultado[:falsosPositivos]].max,
				[acumulado[3],resultado[:falsosNegativos]].max,
			]
			end
			
			#Colocamos un número muy grande ya que realizamos una inyección para crear el arreglo
			@minimos = @resultados.inject([5000000000.0,5000000000.0,5000000000.0,5000000000.0]) do |acumulado, resultado| 
			[ 
				[acumulado[0],resultado[:acertoConElPrimero]].min,
				[acumulado[1],resultado[:aciertos]].min,
				[acumulado[2],resultado[:falsosPositivos]].min,
				[acumulado[3],resultado[:falsosNegativos]].min,
			]
			end
		end

		if @imprimirTodo
			#Resultados contiene los t experimentos
			@resultados.each do |resultado|
				puts "#{@numeroVeces},#{@numeroPuntos},#{@numeroDimensiones},#{resultado[:acertoConElPrimero]},#{desviaciones[0]},#{resultado[:aciertos]},#{desviaciones[1]},#{resultado[:falsosPositivos]},#{desviaciones[2]},#{resultado[:falsosNegativos]},#{desviaciones[3]},#{resultado[:mayorDesplazamiento]},#{0},#{0},#{0}"		
			end
		else
			if @csv
					puts "#{@numeroVeces},#{@numeroPuntos},#{@numeroDimensiones},#{promedios[0]},#{desviaciones[0]},#{promedios[1]},#{desviaciones[1]},#{promedios[2]},#{desviaciones[2]},#{promedios[3]},#{desviaciones[3]},#{promedios[4]},#{desviaciones[4]},#{promedios[5]},#{promedios[5]*100.0/@numeroPuntos}"		
				else
				if @minmax
					puts "#{@numeroVeces},#{@numeroPuntos},#{@numeroDimensiones},#{promedios[0]},#{@maximos[0]},#{@minimos[0]},#{desviaciones[0]},#{promedios[1]},#{@maximos[1]},#{@minimos[1]},#{desviaciones[1]},#{promedios[2]},#{@maximos[2]},#{@minimos[2]},#{desviaciones[2]},#{promedios[3]},#{promedios[3]},#{@maximos[3]},#{desviaciones[3]},#{promedios[4]},#{@minimos[3]},#{desviaciones[3]},#{desviaciones[4]},#{promedios[5]},#{promedios[5]*100.0/@numeroPuntos}"		

				else
					  puts "TOTAL: #{@numeroVeces} experimentos con #{@numeroPuntos} puntos de #{@numeroDimensiones} dimensiones."  
					  puts "Acertó con el primero: #{promedios[0]}% σ=#{desviaciones[0]}."
					  puts "  - Aciertos: #{promedios[1]}% σ=#{desviaciones[1]}\n  - Falsos positivos: #{promedios[2]}% σ=#{desviaciones[2]}\n  - Falsos negativos: #{promedios[3]}% σ=#{desviaciones[3]}\n  - Mayor desplazamiento promedio: #{promedios[4]} σ=#{desviaciones[4]}\n  - Máximo desplazamiento: #{promedios[5]} (#{promedios[5]*100.0/@numeroPuntos}%)"
				end
			end
		end
	end
end

#--------------------------------------------------
# Programa principal
if __FILE__ == $0
	#srand(1)
	srand(Time.now.to_i)
	argumentos = Argumentos.new(ARGV)

	if argumentos[:minmax]
		puts "Número de experimentos, Número de puntos, Número de dimensiones, Aciertos en el primero(%), Maximo aciertos primero, Minimo Aciertos Primero, Desviación Típica Aciertos con el primero, Aciertos(%), Maximo de aciertos, Minimo de aciertos, Desviación Típica Aciertos, Falsos positivos(%), Maximo Falsos positivos, Minimo Falsos positivos, Desviación Típica Falsos positivos, Falsos negativos(%), Maximo falsos negativos, Minimo falsos negativos, Desviación Típica Falsos negativos,Mayor desplazamiento promedio,Desviación Típica Mayor desplazamiento promedio,Máximo desplazamiento,Máximo desplazamiento porcentual"
	else
		#if argumentos[:csv]
		puts "Número de experimentos, Número de universidades, Número de factores a evaluar, Aciertos en el primero(%), Desviación Típica Aciertos con el primero, Aciertos(%), Desviación Típica Aciertos, Falsos positivos(%), Desviación Típica Falsos positivos, Falsos negativos(%), Desviación Típica Falsos negativos,Mayor desplazamiento promedio,Desviación Típica Mayor desplazamiento promedio,Máximo desplazamiento,Máximo desplazamiento porcentual"
	end
	archivos = ARGV
	puts argumentos[:numFactoresAEvaluar]
	puts argumentos[:numUniversidades]
	if argumentos[:rand] or archivos.size == 0
		for numFactoresAEvaluar in 2..argumentos[:numFactoresAEvaluar]
			for numUniversidades in 2..argumentos[:numUniversidades]
				e = Experimentos.new(argumentos[:times], numUniversidades, numFactoresAEvaluar, argumentos[:csv], argumentos[:todo], argumentos[:minmax],nil)
				e.ejecutar
				e.imprimir
			end
		end
		else
		archivos.each do |archivoEntrada|
			e = Experimentos.new(argumentos[:times], nil, nil, argumentos[:csv], argumentos[:todo], argumentos[:minmax], archivoEntrada)
			e.ejecutar
			e.imprimir
		end
	end
end
