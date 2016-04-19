# encoding: utf-8
# Archivo: pruebas_steps.rb
# Autor: Ángel García Baños <angel.garcia@correounivalle.edu.co>
# Autor: Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>
# Autor: Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>
# Fecha creación: 2015-12-15
# Fecha última modificación: 2016-02-06
# Versión: 0.1
# Licencia: GPL

Dado(/^que se crea una constante K que vale (\d+)\.(\d+)$/) do |entero, decimal|
  expect(entero).to eq("0") 
  expect(decimal).to eq("6") 
end

Dado(/^que se crea una constante D que vale (\d+)$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se crea un punto A de D dimensiones cuyas coordenadas son todas mayores que K$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se crea un punto B de D dimensiones cuyas coordenadas son todas menores que K$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces(/^A domina a B$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces(/^B no domina a A$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se cambia la coordenada (\d+) de A para que quede menor que K$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces(/^A no domina a B$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se copia A en B$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces(/^B domina a A$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se crea un conjunto de puntos vacío P$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se añade al conjunto P muchos puntos de D dimensiones cuyas coordenadas son todas menores que K$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se copia A en C$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se cambia la coordenada (\d+) de B para que quede menor que K$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se cambia la coordenada (\d+) de C para que quede menor que K$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se añade al conjunto P el punto A$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se añade al conjunto Q el punto A$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se añade al conjunto P el punto B$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se añade al conjunto Q el punto B$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se añade al conjunto P el punto C$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^se añade al conjunto Q el punto C$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces(/^el óptimo de pareto de P es Q$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^tengo un ranking \[(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)\]$/) do |arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9|
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando(/^una frontera de Pareto \[(\d+),(\d+),(\d+),(\d+)\]$/) do |arg1, arg2, arg3, arg4|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces(/^los puntos \[(\d+),(\d+),(\d+),(\d+)\] del ranking son falsos positivos y los puntos \[(\d+),(\d+)\] son falsos negativos$/) do |arg1, arg2, arg3, arg4, arg5, arg6|
  pending # Write code here that turns the phrase above into concrete actions
end


#Dado /^que se crea una constante '(.*?)' que vale '(.*?)'$/ do |nombre, valor|
	#expect(nombre).to eq("K")
	#expect(valor).to eq(0.6)	 
#end


#Cuando /^se crea un punto '(.*?)' de '(.*?)' dimensiones cuyas coordenadas son todas '[mayor|menor]'es que '(.*?)'$/ do |punto, dimension, mayor_menor, limite|
#pending
#end


#Y /^'(.*?)' '((no )?)' domina a '(.*?)'$/ do |si_no, punto1, punto2|
#pending
#end


#Y /^se cambia la coordenada '(.*?)' de '(.*?)' para que quede '[mayor|menor]' que '(.*?)'$/ do |coordenada, punto, mayor_menor, limite|
#pending
#end


#Y /^se copia '(.*?)' en '(.*?)'$/ do |punto1, punto2|
#pending
#end


#Cuando /^se crea un conjunto de puntos vacío '(.*?)'$/ do |conjunto|
#pending
#end


#Y /^se añade al conjunto '(.*?)' muchos puntos de '(.*?)' dimensiones cuyas coordenadas son todas '[mayor|menor]'es que '(.*?)'$/ do |conjunto, dimension, mayor_menor, limite|
#pending
#end


#Y /^se añade al conjunto '(.*?)' el punto '(.*?)'$/ do |conjunto, punto|
#pending
#end


#Entonces /^el óptimo de pareto de  es '(.*?)'$/ do |conjunto1, conjunto2|
#pending
#end


#Cuando /^tengo un ranking '(.*?)'$/ do |ranking|
  #@ranking = ranking
#end


#Y /^una frontera de Pareto '(.*?)'$/ do |fronteraPareto|
  #@fronteraPareto = fronteraPareto
#end


#Entonces /^los puntos '(.*?)' del ranking son falsos positivos y los puntos '(.*?)' son falsos negativos$/ do |falsosPositivos, falsosNegativos|
#pending
#end







