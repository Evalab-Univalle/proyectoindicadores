# language: es
# encoding: utf-8
# Archivo: CapturarErroresEnSSARA.feature
# Autor: Ángel García Baños <angel.garcia@correounivalle.edu.co>
# Autor: Carlos Andrés Delgado Saavedra <carlos.andres.delgado@correounivalle.edu.co>
# Autor: Víctor Andrés Bucheli Guerrero <victor.bucheli@correounivalle.edu.co>
# Fecha creación: 2015-12-15
# Fecha última modificación: 2016-05-06
# Versión: 0.1
# Licencia: GPL

Característica: verificar que se calcula correctamente la dominancia y la frontera de Pareto

  Antecedentes: Se crea una constante y el número de dimensiones
    Dado que se crea una constante real K que vale 0.6
    Y que se crea una constante entera D que vale 30
   
@dominancia
  Escenario: A es peor que B: A es dominado por B; B no es dominado por A
    Cuando se crea un punto A de D dimensiones cuyas coordenadas son todas menores que K
    Y se crea un punto B de D dimensiones cuyas coordenadas son todas mayores que K
    Entonces A es dominado por B
    Y B no es dominado por A

  Escenario: No hay ningún punto mejor que el otro: A no es dominado por B; B no es dominado por A
    Cuando se crea un punto A de D dimensiones cuyas coordenadas son todas mayores que K
    Y se crea un punto B de D dimensiones cuyas coordenadas son todas menores que K
    Y se cambia la coordenada 1 de A para que quede menor que K
    Y se cambia la coordenada 1 de B para que quede mayor que K
    Entonces A no es dominado por B
    Y B no es dominado por A

  Escenario: Los puntos son iguales: A no es dominado por B y B no es dominado por A
    Cuando se crea un punto A de D dimensiones cuyas coordenadas son todas mayores que K
    Y se copia A en B
    Entonces A no es dominado por B
    Y B no es dominado por A
    
@frontera    
  Escenario: óptimo de Pareto
    Cuando se crea un conjunto de puntos vacío P
    Y se crea un conjunto de puntos vacío Q
    Y se añaden 5 puntos de D dimensiones al conjunto P, cuyas coordenadas son todas menores que K
    Y se crea un punto A de D dimensiones cuyas coordenadas son todas mayores que K
    Y se añade el punto A al conjunto P
    Y se añade el punto A al conjunto Q
    Entonces el óptimo de pareto de P es Q
        
  Escenario: óptimo de Pareto
    Cuando se crea un conjunto de puntos vacío P
    Y se crea un conjunto de puntos vacío Q
    Y se crea un punto A de D dimensiones cuyas coordenadas son todas mayores que K
    Y se copia A en B
    Y se copia A en C
    Y se cambia la coordenada 1 de A para que quede menor que K
    Y se cambia la coordenada 2 de B para que quede menor que K
    Y se cambia la coordenada 3 de C para que quede menor que K
    Y se añade el punto A al conjunto P
    Y se añade el punto A al conjunto Q
    Y se añade el punto B al conjunto P
    Y se añade el punto B al conjunto Q
    Y se añade el punto C al conjunto P
    Y se añade el punto C al conjunto Q
    Entonces el óptimo de pareto de P es Q

@falsos
  Escenario: Contar falsos positivos y falsos negativos
    Cuando tengo un ranking [1,2,3,4,5,6,7,8,9,10]
    Y una frontera de Pareto [1,2,6,8]
    Entonces los puntos [1,2,9,10] del ranking son aciertos, los puntos [3,4,5,7] son falsos positivos y los puntos [6,8] son falsos negativos
    
@maxYmin
  Escenario: 
    
    
    
    
    
    
