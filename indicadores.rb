#!/usr/bin/env ruby
# encoding: utf-8
# Archivo: indicadores.rb
# Autor: Ángel García Baños <angel.garcia@correounivalle.edu.co>
# Autor: Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>
# Autor: Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>
# Fecha creación: 2015-12-15
# Fecha última modificación: 2016-05-07
# Versión: 0.2
# Licencia: GPL
#--------------------------------------------------
# Utilidad: Para mostrar lo equivocado que es linealizar indicadores.
#--------------------------------------------------
# VERSIONES
# 0.2 Refactorizada la clase punto. Ahora hereda de Array.
# 0.1 Inicial
#--------------------------------------------------
# Para ayudar a depurar:
def dd(n, a)
  p "[#{n}] #{a.inspect}"
  p "===="
end
#--------------------------------------------------



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
  # - Se elige un punto al azar y se busca cuales pesos maximizan/minimizan su posición en el ranking. Se guarda en los resultados la diferencia entre la posición máxima en el ranking y la mínima conseguidas.
  # - Se elige otro punto al azar, y se intenta buscar un juego de pesos que invierta sus posiciones en el ranking. Si ésto se logra, se anota en los resultados.
  def ejecutarTodasLasPruebas
    resultado = Hash.new(0) # Por default, los valores inexistentes son 0
    fronteraPareto = calcularFronteraPareto()
puts "Frontera de Pareto: #{fronteraPareto}"
    ranking = self.sort_by { |x| x.promedio }.reverse
    resultado[:acertoConElPrimero] = (fronteraPareto.include?(ranking[0]) ? 1 : 0)
    aciertos, positivos, negativos = aciertosYFallos(fronteraPareto, ranking)
    resultado[:aciertos], resultado[:falsosPositivos], resultado[:falsosNegativos] = aciertos.length, positivos.length, negativos.length
    puntoElegidoAlAzar = self.sample
    rankingMaximo = maximizarRanking(puntoElegidoAlAzar)
    rankingMinimo = minimizarRanking(puntoElegidoAlAzar)
    if rankingMaximo < rankingMinimo
      puts "ERROR INTERNO"
      puts "Ranking: #{ranking}"
      puts "Punto Elegido al azar: #{puntoElegidoAlAzar}"
      puts "Ranking máximo: #{rankingMaximo}"
      puts "Ranking mínimo: #{rankingMinimo}"
    end
    resultado[:diferenciaRanking] = rankingMaximo - rankingMinimo
    resultado[:inversiones] = (invertirRanking(puntoElegidoAlAzar, self.sample) ? 1 : 0)
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
  
  # ESTO NO ESTÁ BIEN. EL RANKING DE UN PUNTO DEPENDE TAMBIÉN DE TODOS LOS DEMÁS PUNTOS. ???
  # Se calculan los pesos que maximizan el ranking de un punto, con la restricción de que todos los pesos deben valer entre 0 y 1; y la suma de todos los pesos debe valer 1.
  # Para lograrlo lo que hay que hacer es maximizar el resultado ponderado y como la ponderación es lineal, hay que poner peso 1 al indicador de mayor valor y peso 0 a los demás.
  # Retorna el máximo valor del ranking alcanzado. El ranking está ordenado de menor a mayor, de modo que cuanto más grande sea el número que retorne, mejor es su posición.
  def maximizarRanking(punto)
    indice_indicador_max  = punto.each_with_index.max[1]
    pesos = Array.new(punto.length, 0)
    pesos[indice_indicador_max] = 1
    ranking = self.sort_by { |x| x.ponderado(pesos) }
    ranking.find_index(punto)
  end
  
  # ESTO NO ESTÁ BIEN. EL RANKING DE UN PUNTO DEPENDE TAMBIÉN DE TODOS LOS DEMÁS PUNTOS. ???
  # Se calculan los pesos que minimizan el ranking de un punto, con la restricción de que todos los pesos deben valer entre 0 y 1; y la suma de todos los pesos debe valer 1. 
  # Para lograrlo lo que hay que hacer es minimizar el resultado ponderado y como la ponderación es lineal, hay que poner peso 1 al indicador de menor valor y peso 0 a los demás.
  # Retorna el mínimo valor del ranking alcanzado. El ranking está ordenado de menor a mayor, de modo que cuanto más pequeño sea el número que retorne, peor es su posición.
  def minimizarRanking(punto)
    indice_indicador_min  = punto.each_with_index.min[1]
    pesos = Array.new(punto.length, 0)
    pesos[indice_indicador_min] = 1
    ranking = self.sort_by { |x| x.ponderado(pesos) }
    ranking.find_index(punto)
  end

  # ESTO HAY QUE HACERLO CON ALGORITMOS GENÉTICOS o SUPRIMIRLO???
  # Se intenta invertir el orden en el ranking de dos puntos. Si se logra, se retorna true, y si no, false.
  def invertirRanking(unPunto, otroPunto)
    # ToDo
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
  def initialize(numeroVeces, numeroPuntos, numeroDimensiones)
    @numeroVeces, @numeroPuntos, @numeroDimensiones = numeroVeces, numeroPuntos, numeroDimensiones
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
    promedios = @resultados.inject([0,0,0,0,0,0]) { |acumulado, resultado| [ acumulado[0]+resultado[:acertoConElPrimero], 
                                                                             acumulado[1]+resultado[:aciertos], 
                                                                             acumulado[2]+resultado[:falsosNegativos], 
                                                                             acumulado[3]+resultado[:falsosPositivos], 
                                                                             acumulado[4]+resultado[:diferenciaRanking], 
                                                                             acumulado[5]+resultado[:inversiones] ] 
                                                  }
    promedios.collect! { |x| x/nv }
    
    # Se saca la desviación típica de cada resultado:
    desviaciones = @resultados.inject([0,0,0,0,0,0]) { |acumulado, resultado| [ acumulado[0]+(resultado[:acertoConElPrimero]-promedios[0])**2,
                                                                                acumulado[1]+(resultado[:aciertos]-promedios[1])**2,
                                                                                acumulado[2]+(resultado[:falsosNegativos]-promedios[2])**2,
                                                                                acumulado[3]+(resultado[:falsosPositivos]-promedios[3])**2,
                                                                                acumulado[4]+(resultado[:diferenciaRanking]-promedios[4])**2,
                                                                                acumulado[5]+(resultado[:inversiones]-promedios[5])**2 ]
                                                     }

    desviaciones.collect! { |x| Math.sqrt(x/nv).to_i }
    promedios.collect! { |x| x.to_i }
    
    puts "TOTAL: #{@numeroVeces} experimentos con #{@numeroPuntos} puntos de #{@numeroDimensiones} dimensiones."  
    puts "Acertó con el primero: #{promedios[0]*100}% ± #{desviaciones[0]}.  Inversiones: #{promedios[5]*100}% ± #{desviaciones[5]}.  Distancia promedio al cambiar de orden: #{promedios[4]}."
    puts "  - Aciertos: #{promedios[1]*100/np}% ± #{desviaciones[1]}\n  - Falsos positivos: #{promedios[2]*100/np}% ± #{desviaciones[2]}\n  - Falsos negativos: #{promedios[3]*100/np}% ± #{desviaciones[3]}"
  end
end



#--------------------------------------------------
# Programa principal
if __FILE__ == $0
  for i in 2..8
    e = Experimentos.new(30, 4, i)
    e.ejecutar
    p "==#{i}=="
    e.imprimir
  end
end

