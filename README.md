# Proyecto indicadores

Esta aplicación es realizada para realizar pruebas en un proyecto interno del grupo, en el cual se pretende demostrar que los rankings utilizados actualmente están sesgados.

## Forma de uso

#### Salida en formato CSV
```bash
ruby indicadores.rb --csv
```
#### Obtener todos los datos de los experimentos en formato CSV
```bash
ruby indicadores.rb --csv
```
#### Ingresar las Universidades y número de indicadores (aplica para todas las combinaciones)
```bash
ruby indicadores.rb -u=X -i=Y
```
**X e Y son enteros mayores que 0.**
#### Especificar el número de experimentos
```bash
ruby indicadores.rb -t=X
```
**X es mayor que 0.**
#### Obtener ayuda
```bash
ruby indicadores.rb -h
```
#### Obtener versión
```bash
ruby indicadores.rb -v
```
###Ejemplo
```bash
ruby indicadores.rb --minmax  -r  >  ../experimentos24Febrero.csv
```
