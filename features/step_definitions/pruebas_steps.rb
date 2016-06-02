# encoding: utf-8
# Archivo: pruebas_steps.rb
# Autor: Ángel García Baños <angel.garcia@correounivalle.edu.co>
# Autor: Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>
# Autor: Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>
# Fecha creación: 2015-12-15
# Fecha última modificación: 2016-05-10
# Versión: 0.1
# Licencia: GPL


CAPTURA_UN_ENTERO = Transform /^\d+$/ do |valor|
  valor.to_i
end


CAPTURA_UN_FLOTANTE = Transform /^\d+\.\d+$/ do |valor|
  valor.to_f
end


Before do
  @constantes = Hash.new
  @puntos = Hash.new
  @conjuntos = Hash.new
end


#-- Pruebas Punto --------------------------

Dado /^que se crea una constante real (.*?) que vale (#{CAPTURA_UN_FLOTANTE})$/ do |nombre, valor|
  @constantes[nombre] = valor
end


Dado /^que se crea una constante entera (.*?) que vale (#{CAPTURA_UN_ENTERO})$/ do |nombre, valor|
  @constantes[nombre] = valor
end


Cuando /^se crea un punto (.*?) de (.*?) dimensiones cuyas coordenadas son todas (mayor|menor)es que (.*?)$/ do |punto, numeroDimensiones, mayor_menor, limite|
  if mayor_menor == "mayor"
    @puntos[punto] = Punto.new(@constantes[numeroDimensiones], @constantes[limite]+0.0001, 1.0)
  else
    @puntos[punto] = Punto.new(@constantes[numeroDimensiones], 0.0, @constantes[limite])
  end
end


Y /^(.*?) (no )?es dominado por (.*?)$/ do |punto1, si_no, punto2|
  if si_no == "no "
    expect(@puntos[punto1].dominado_por?(@puntos[punto2])).to be false
  else
    expect(@puntos[punto1].dominado_por?(@puntos[punto2])).to be true
  end
end


Y /^se cambia la coordenada (#{CAPTURA_UN_ENTERO}) de (.*?) para que quede (mayor|menor) que (.*?)$/ do |coordenada, punto, mayor_menor, limite|
  @puntos[punto].cambiarIndicador(coordenada, (@constantes[limite]+(mayor_menor=="mayor" ? 1 : 0))/2.0)
end


Y /^se copia (.*?) en (.*?)$/ do |punto1, punto2|
  @puntos[punto2] = @puntos[punto1].clone
end




#-- Pruebas Experimento --------------------------

Cuando /^se crea un conjunto de puntos vacío (.*?)$/ do |conjunto|
  @conjuntos[conjunto] = Experimento.new()
end


Y /^se añaden? (#{CAPTURA_UN_ENTERO}) puntos? de (.*?) dimensiones al conjunto (.*?), cuyas coordenadas son todas (mayor|menor)es que (.*?)$/ do |cantidad, numeroDimensiones, conjunto, mayor_menor, limite|
  cantidad.times do
    if mayor_menor == "mayor"
      punto = Punto.new(@constantes[numeroDimensiones], @constantes[limite]+0.0001, 1.0)
    else
      punto = Punto.new(@constantes[numeroDimensiones], 0.0, @constantes[limite])
    end
    @conjuntos[conjunto].añadirPunto(punto)
  end
end


Y /^se añade el punto (.*?) al conjunto (.*?)$/ do |punto, conjunto|
  @conjuntos[conjunto].añadirPunto(@puntos[punto])
end


Entonces /^el óptimo de pareto de (.*?) es (.*?)$/ do |conjunto1, conjunto2|
  expect(@conjuntos[conjunto1].calcularFronteraPareto).to match_array(@conjuntos[conjunto2])
end


Cuando /^tengo un ranking (.*?)$/ do |ranking|
  @ranking = eval(ranking)
end


Y /^una frontera de Pareto (.*?)$/ do |fronteraPareto|
  @fronteraPareto = eval(fronteraPareto)
end


Entonces /^los puntos (.*?) del ranking son aciertos, los puntos (.*?) son falsos positivos y los puntos (.*?) son falsos negativos$/ do |aciertos, falsosPositivos, falsosNegativos|
  experimento = Experimento.new
  aciertosTest, falsosPositivosTest, falsosNegativosTest = experimento.aciertosYFallos(@fronteraPareto, @ranking)
  expect(aciertosTest).to eq(eval(aciertos))
  expect(falsosPositivosTest).to eq(eval(falsosPositivos))
  expect(falsosNegativosTest).to eq(eval(falsosNegativos))
end


require 'tempfile'

Cuando /^tengo un archivo con '(.*?)'$/ do |contenidoArchivo|
  contenidoArchivo.gsub!("\\n", "\n").gsub!("\\t", "\t").delete!("\"")
  out = Tempfile.new("tempfile")
  @archivoTemporal = out.path
puts contenidoArchivo
  out.puts contenidoArchivo
  out.close
end


Y /^pido leer el archivo$/ do
  @experimento = Experimento.new
end


Entonces /^todo debe ir bien$/ do
  expect{ @experimento.añadirPuntos(@archivoTemporal) }.not_to raise_error
end


Entonces /^debe indicar que la primera línea es incorrecta$/ do
  expect{ @experimento.añadirPuntos(@archivoTemporal) }.to raise_error(ArgumentError, "#<ArgumentError: La primera línea del archivo #{@archivoTemporal} tiene un formato desconocido. Debería ser n\tUniversity\tEconomy\tOverall\t...".gsub!("\\t", "\t"))
end


Entonces /^debe indicar que le faltan indicadores a la primera línea$/ do
  expect{ @experimento.añadirPuntos(@archivoTemporal) }.to raise_error(ArgumentError, "A la primera línea del archivo #{@archivoTemporal} le faltan los nombres de los indicadores después de: n\tUniversity\tEconomy\tOverall\t...".gsub!("\\t", "\t"))
end


Entonces /^debe indicar que le faltan o sobran columnas a la línea (.*?)$/ do |numLinea|
  expect{ @experimento.añadirPuntos(@archivoTemporal) }.to raise_error(ArgumentError, "En el archivo #{@archivoTemporal}, la línea #{numLinea} tiene un número de columnas distinto a la primera línea del archivo")
end





