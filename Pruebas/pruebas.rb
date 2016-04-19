a = []
numeroDimensiones = 10
valorMinimo = 0.0
valorMaximo = 1.0
numeroDimensiones.times { a << rand(valorMinimo..valorMaximo) }
p a

exit
a=[1,2,3,4]
  p (a.inject(0) { |suma, x| suma+x }) 

exit
a = [1,4,3]
b = [4,5,6]
a.zip(b).each { |d1,d2| p "false" if d1 > d2 }
p "fin"


