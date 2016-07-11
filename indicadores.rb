#!/usr/bin/env ruby
# encoding: utf-8
# File: indicadores.rb
Copyright = 
"Ángel García Baños <angel.garcia@correounivalle.edu.co>\n" +
"Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>\n" +
"Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>\n" +
"Institution: EISC, Universidad del Valle, Colombia\n" +
"Creation date: 2015-12-15\n" +
"Last modification date: 2016-05-13\n" +
"License: GNU-GPL"
Version = "0.3"
Description = "To verify linearising indicators"
Dependences = "Nothing"
#--------------------------------------------------
# VERSIONES
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
    options = OptionParser.new do |option|
      option.banner = "Use: #$0 [options]\n\n" + Description + "\n\n" + Copyright + "\nVersion: " + Version + "\nOptions:\n" + "Dependences:\n" + Dependences

      option.on('-c', '--csv', 'output in csv format') do
        self[:csv] = true
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
  # Crea el punto don el número de dimensiones especificado. En cada dimensión se pone un indicador generado al azar entre 0 y 1.
  # Calcula el promedio simple de todos los indicadores (es decir, con todos los pesos igual a 1/numeroDimensiones).
  def initialize(numeroDimensiones, valorMinimo=0.0, valorMaximo=1.0)
    @numeroDimensiones, @valorMinimo, @valorMaximo = numeroDimensiones, valorMinimo, valorMaximo
    @numeroDimensiones.times { self << rand(valorMinimo..valorMaximo) }
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
  
  #Calcula el promedio de todos los indicadores.
  def promedio
    (self.inject(0.0) { |suma, x| suma+x }) / @numeroDimensiones.to_f
  end
  
  # Calcula el promedio ponderado de todos los indicadores, a partir de un vector de pesos que recibe como entrada.
  def ponderado(pesos)
    a = self.zip(pesos).inject(0.0) { |suma, coordenada_y_peso| suma+coordenada_y_peso[0]*coordenada_y_peso[1] }
  end
  
  # Cambia un indicador del punto. Esta función solo sirve para facilitar el test de esta clase.
  def cambiarIndicador(cualIndicador, nuevoValor)
    self[cualIndicador] = nuevoValor
  end
  
  # Copia profunda.
  def clone
    otroPunto = Punto.new(@numeroDimensiones, @valorMinimo, @valorMaximo)
    otroPunto.clear
    self.each { |item| otroPunto << item }
    otroPunto
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
    numeroPuntos.times { añadirPunto(Punto.new(numeroDimensiones)) }
  end
  
  # Añade un punto al conjunto.
  def añadirPunto(punto)
    self << punto
  end
  
  # Ejecuta el experimento de comparar óptimos de Pareto contra óptimos lineales. Retorna un hash con los resultados.
  # Para ello:
  # - Crea el conjunto de puntos. Cada punto es un vector de indicadores. Y el promedio de todos los indicadores va a darnos la bondad de esepunto según el algoritmo de linealizar.
  # - Calcula la frontera de Pareto de ese conjunto de puntos.
  # - Ordena los puntos en un ranking de mayor a menor (es decir, linealiza todas las funciones en una única), usando para ello su promedio de indicadores. 
  # - Si el primer punto del ranking pertenece a la frontera de Pareto, entonces el algoritmo de linealizar acertoConElPrimero y se anota ello en sus resultados.
  # - Si los "i" primeros del ranking pertenecen a la frontera de Pareto, entonces el algoritmo de linealizar acertó en "i" casos, y se anota ello en sus resultados. 
  # - Se calculan los falsos positivos (están bien situados en el ranking, pero no forman parte de la frontera de Pareto) y los falsos negativos (están en la frontera de Pareto, pero se encuentran mal situados en el ranking) y se guarda cuantos hay de cada uno en los resultados. 
  def ejecutarTodasLasPruebas
    resultado = Hash.new(0) # Por default, los valores inexistentes son 0
    fronteraPareto = calcularFronteraPareto()
    ranking = self.sort_by { |x| x.promedio }.reverse
    resultado[:acertoConElPrimero] = (fronteraPareto.include?(ranking[0]) ? 1 : 0)
    aciertos, positivos, negativos = aciertosYFallos(fronteraPareto, ranking)
    resultado[:aciertos], resultado[:falsosPositivos], resultado[:falsosNegativos] = aciertos.length, positivos.length, negativos.length
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
end


#--------------------------------------------------
# Se repite el experimento un número determinado de veces, para generar estadísticas de los resultados.
class Experimentos
  def initialize(numeroVeces, numeroPuntos, numeroDimensiones, csv)
    @numeroVeces, @numeroPuntos, @numeroDimensiones, @csv = numeroVeces, numeroPuntos, numeroDimensiones, csv
  end
  
  def ejecutar
    @resultados = []
    @numeroVeces.times do
      experimento = Experimento.new
      experimento.añadirPuntosAlAzar(@numeroPuntos, @numeroDimensiones)
      @resultados << experimento.ejecutarTodasLasPruebas
    end
  end
  
  def imprimir
    nv = @numeroVeces.to_f
    np = @numeroPuntos.to_f
    promedios = @resultados.inject([0.0,0.0,0.0,0.0]) do |acumulado, resultado| 
      [ 
        acumulado[0]+resultado[:acertoConElPrimero],
        acumulado[1]+resultado[:aciertos],
        acumulado[2]+resultado[:falsosNegativos],
        acumulado[3]+resultado[:falsosPositivos]
      ] 
    end
    
    promedios.collect! { |x| x/(nv*np) }
    promedios[0] *= np
    
    # Se saca la desviación típica de cada resultado:
    desviaciones = @resultados.inject([0.0,0.0,0.0,0.0]) do |acumulado, resultado| 
      [ 
        acumulado[0]+(resultado[:acertoConElPrimero]-promedios[0])**2,
        acumulado[1]+(resultado[:aciertos]-promedios[1])**2,
        acumulado[2]+(resultado[:falsosNegativos]-promedios[2])**2,
        acumulado[3]+(resultado[:falsosPositivos]-promedios[3])**2
      ]
    end
    
    promedios.collect! { |x| x*100.0 }
    desviaciones.collect! { |x| Math.sqrt(x*100.0/(nv*np)) }
    desviaciones[0] *= np

    if @csv
      puts "#{@numeroVeces},#{@numeroPuntos},#{@numeroDimensiones},#{promedios[0]},#{desviaciones[0]},#{promedios[1]},#{desviaciones[1]},#{promedios[2]},#{desviaciones[2]},#{promedios[3]},#{desviaciones[3]}"
    else
      puts "TOTAL: #{@numeroVeces} experimentos con #{@numeroPuntos} puntos de #{@numeroDimensiones} dimensiones."  
      puts "Acertó con el primero: #{promedios[0]}% ± #{desviaciones[0]}."
      puts "  - Aciertos: #{promedios[1]}% ± #{desviaciones[1]}\n  - Falsos positivos: #{promedios[2]}% ± #{desviaciones[2]}\n  - Falsos negativos: #{promedios[3]}% ± #{desviaciones[3]}"
    end
  end
end

#--------------------------------------------------
# Programa principal
if __FILE__ == $0
  srand(1)
  argumentos = Argumentos.new(ARGV)
  if argumentos[:csv]
    puts "Número de experimentos, Número de puntos, Número de dimensiones, Aciertos en el primero(%), Desviación Típica Aciertos con el primero, Aciertos(%), Desviación Típica Aciertos, Falsos positivos(%), Desviación Típica Falsos positivos, Falsos negativos(%), Desviación Típica Falsos negativos"
  end
  for numDimensiones in 18..20
    for numPuntos in 2..100
      e = Experimentos.new(300, numPuntos, numDimensiones, argumentos[:csv])
      e.ejecutar
      e.imprimir
    end
  end
end

