#!/usr/bin/env ruby
# encoding: utf-8
# Archivo: indicadores.rb
# Autor: Ángel García Baños <angel.garcia@correounivalle.edu.co>
# Autor: Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>
# Autor: Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>
# Fecha creación: 2015-12-15
# Fecha última modificación: 2016-04-19
# Versión: 0.1
# Licencia: GPL

# VERSIONES
# 0.1 Inicial

###########################################################################################
# Para mostrar lo equivocado que es linealizar indicadores.
###########################################################################################

# Para ayudar a depurar:
def dd(n, a)
  p "[#{n}] #{a.inspect}"
  p "===="
end


###########################################################################################
# Un punto es un vector de indicadores (valores entre 0 y 1). Por ejemplo, una universidad con sus indicadores de publicaciones, docencia, investigación, etc. O un estudiante con cada una de las calificaciones de las asignaturas que ha cursado. Etc. Cuanto mayor es el valor del indicador, mejor.
class Punto
  attr_reader :promedio, :p
  
  # Crea el punto don el número de dimensiones especificado. En cada dimensión se pone un indicador generado al azar entre 0 y 1.
  # Calcula el promedio simple de todos los indicadores (es decir, con todos los pesos igual a 1/numeroDimensiones).
  def initialize(numeroDimensiones, valorMinimo=0.0, valorMaximo=1.0)
    @p = []
    numeroDimensiones.times { @p << rand(valorMinimo..valorMaximo) }
    @promedio = (@p.inject(0.0) { |suma, x| suma+x }) / numeroDimensiones
  end

  # Verifica si el punto está dominado por otro punto, es decir, si cada uno de los indicadores del otro punto es mejor (mayor o igual). 
  # Retorna true si está dominado por el otro punto, y false en caso contrario.
  def dominado_por?(otroPunto)
    @p.zip(otroPunto.p).each { |d1, d2| return false if d1 > d2 }
    return true
  end

  # Verifica si el punto no está dominado por ningún otro, de un vector de puntos que recibe como entrada.
  # Retorna true si no está dominado por ninguno y false si está dominado por al menos uno.
  def dominado_por_ningun?(puntos)
    puntos.each { |punto| return false if dominado_por?(punto) }
    return true
  end
  
  # Calcula, memoriza y retorna el promedio ponderado de todos los indicadores, a partir de un vector de pesos que recibe como entrada.
  def ponderado(pesos)
    @promedio = @p.zip(pesos).inject(0.0) { |suma, coordenada, peso| suma+coordenada*peso }
  end
  
  # Cambia un indicador del punto. Esta función solo sirve para facilitar el test de esta clase.
  def cambiarIndicador(cualIndicador, nuevoValor)
    @p[cualIndicador] = nuevoValor
  end
end


# Un experimento consiste en generar al azar un número determinado de puntos con un número determinado de dimensiones. 
# Luego se puede comparar la frontera de Pareto de ese conjunto de puntos con el resultado de buscar el óptimo linealizando los indicadores.
class Experimento
  # Define el número de puntos y el número de dimensiones de los puntos
  def initialize(numeroPuntos, numeroDimensiones)
    @numeroPuntos, @numeroDimensiones = numeroPuntos, numeroDimensiones
  end
  
  # Ejecuta el experimento de comparar óptimos de Pareto contra óptimos lineales. Retorna un hash con los resultados.
  # Para ello:
  # - Crea el conjunto de puntos. Cada punto es un vector de indicadores. Y el promedio de todos los indicadores va a darnos la bondad de esepunto según el algoritmo de linealizar.
  # - Calcula la frontera de Pareto de ese conjunto de puntos.
  # - Ordena los puntos en un ranking de mayor a menor, usando para ello su promedio de indicadores. 
  # - Si el primer punto del ranking (el mejor después de linealizar) pertenece a la frontera de Pareto, entonces el algoritmo de linealizar acertó y se anota ello en sus resultados.
  # - Se calculan los falsos positivos (están bien situados en el ranking, pero no forman parte de la frontera de Pareto) y los falsos negativos (están en la frontera de Pareto, pero se encuentran mal situados en el ranking) y se guarda cuantos hay de cada uno en los resultados. 
  # - Se elige un punto al azar y se busca cuales pesos maximizan/minimizan su posición en el ranking. Se guarda en los resultados la diferencia entre la posición máxima en el ranking y la mínima conseguidas.
  # - Se elige otro punto al azar, y se intenta buscar un juego de pesos que invierta sus posiciones en el ranking. Si ésto se logra, se anota en los resultados.
  def ejecutar
    resultado = Hash.new(0) # Por default, los valores inexistentes son 0
    @puntos = []
    @numeroPuntos.times { @puntos << Punto.new(@numeroDimensiones) }
    fronteraPareto = calcularFronteraPareto(@puntos)
    ranking = @puntos.sort_by { |x| x.promedio }.reverse
    resultado[:aciertos] = 1 if fronteraPareto.include?(ranking[0])
    positivos, negativos = falsos(fronteraPareto, ranking)
    resultado[:falsosPositivos], resultado[:falsosNegativos] = positivos.length, negativos.length
    puntoElegidoAlAzar = @puntos.choice
    rankingMaximo = maximizarRanking(puntoElegidoAlAzar)
    rankingMinimo = minimizarRanking(puntoElegidoAlAzar)
    resultado[:diferenciaRanking] = rankingMaximo - rankingMinimo
    resultado[:inversiones] = 1 if invertirRanking(puntoElegidoAlAzar, @puntos.choice)
    resultado
  end
  
  # Retorna cuantos falsos positivos y cuantos falsos negativos hay.
  def falsos(fronteraPareto, ranking)
    # ToDo
  end
  
  # Se calculan los pesos que maximizan el ranking de un punto, con la restricción de que todos los pesos deben valer entre 0 y 1; y la suma de todos los pesos debe valer 1. Básicamente lo que hay que hacer es maximizar el resultado ponderado y como la ponderación es lineal, hay que poner peso 1 al indicador de mayor valor y peso 0 a los demás. ?????REVISAR A VER SI ES CORRECTO ESTE RAZONAMIENTO.
  # Retorna el máximo valor del ranking alcanzado.
  def maximizarRanking(punto)
    # ToDo
    indice_indicador_max  = punto.each_with_index.max[1]
    pesos = Array.new(@puntos.length, 0)
    pesos[indice_indicador_max] = 1
    @puntos.collect { |punto| punto.ponderado(pesos) }
    ranking = @puntos.sort_by { |x| x.promedio }.reverse
    ranking.find_index(punto)
  end
  
  # Se calculan los pesos que minimizan el ranking de un punto, con la restricción de que todos los pesos deben valer entre 0 y 1; y la suma de todos los pesos debe valer 1. Básicamente lo que hay que hacer es minimizar el resultado ponderado y como la ponderación es lineal, hay que poner peso 1 al indicador de menor valor y peso 0 a los demás. ?????REVISAR A VER SI ES CORRECTO ESTE RAZONAMIENTO.
  # Retorna el máximo valor del ranking alcanzado.
  def minimizarRanking(punto)
    # ToDo
  end

  # Se intenta invertir el orden en el ranking de dos puntos. Si se logra, se retorna true, y si no, false.
  def invertirRanking(unPunto, otroPunto)
    # ToDo
  end
  
  # Retorna la frontera de Pareto de un conjunto de puntos, que está formada por los puntos no dominados por ningún otro.
  def calcularFronteraPareto(puntos)
    resultado = []
    loop do
      punto = puntos.pop
      break if not punto
      resultado << punto if not punto.dominado_por_ninguno?(puntos)
    end
    resultado
  end
end


# Se repite el experimento un número determinado de veces, para generar estadísticas de los resultados.
class Experimentos
  def initialize(numeroPuntos=1000, numeroDimensiones=20, numeroVeces=10000)
    @numeroPuntos, @numeroDimensiones, @numeroVeces = numeroPuntos, numeroDimensiones, numeroVeces
  end
  
  def ejecutar
    @resultados = []
    @numeroVeces.times { @resultados << Experimento.new.ejecutar }  
  end
  
  def imprimir
    p @resultados
  end
end


###########################################################################################
# Programa principal
if __FILE__ == $0
  e = Experimentos.new(1000, 20, 10000)
  e.ejecutar
  e.imprimir
end

