# encoding: utf-8
# Archivo: pruebas_steps.rb
# Autor: Ángel García Baños <angel.garcia@correounivalle.edu.co>
# Autor: Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>
# Autor: Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>
# Fecha creación: 2015-12-15
# Fecha última modificación: 2016-02-06
# Versión: 0.1
# Licencia: GPL


Dado /^que se crea una constante '(.*?)' que vale '(.*?)'$/ do |nombre, valor|
pending
end


Cuando /^se crea un punto '(.*?)' de '(.*?)' dimensiones cuyas coordenadas son todas '[mayor|menor]'es que '(.*?)'$/ do |punto, dimension, mayor_menor, limite|
pending
end


Y /^'(.*?)' '((no )?)' domina a '(.*?)'$/ do |si_no, punto1, punto2|
pending
end


Y /^se cambia la coordenada '(.*?)' de '(.*?)' para que quede '[mayor|menor]' que '(.*?)'$/ do |coordenada, punto, mayor_menor, limite|
pending
end


Y /^se copia '(.*?)' en '(.*?)'$/ do |punto1, punto2|
pending
end


Cuando /^se crea un conjunto de puntos vacío '(.*?)'$/ do |conjunto|
pending
end


Y /^se añade al conjunto '(.*?)' muchos puntos de '(.*?)' dimensiones cuyas coordenadas son todas '[mayor|menor]'es que '(.*?)'$/ do |conjunto, dimension, mayor_menor, limite|
pending
end


Y /^se añade al conjunto '(.*?)' el punto '(.*?)'$/ do |conjunto, punto|
pending
end


Entonces /^el óptimo de pareto de  es '(.*?)'$/ do |conjunto1, conjunto2|
pending
end


Cuando /^tengo un ranking '(.*?)'$/ do |ranking|
  @ranking = ranking
end


Y /^una frontera de Pareto '(.*?)'$/ do |fronteraPareto|
  @fronteraPareto = fronteraPareto
end


Entonces /^los puntos '(.*?)' del ranking son falsos positivos y los puntos '(.*?)' son falsos negativos$/ do |falsosPositivos, falsosNegativos|
pending
end







