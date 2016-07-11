from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import matplotlib.pyplot as plt
import numpy as np
import csv


reader=csv.reader(open("datos.csv","rb"),delimiter=',')
x=list(reader)
result=np.array(x).astype('float')


fig = plt.figure()
ax = fig.gca(projection='3d')
X = result[:,1]
Y = result[:,2]

X, Y = np.meshgrid(X, Y)


Z = result[:,5]
print("Generar grafica")
surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.coolwarm,
                       linewidth=0, antialiased=False)
#ax.set_zlim(-1.01, 1.01)

#ax.zaxis.set_major_locator(LinearLocator(10))
#ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))

fig.colorbar(surf, shrink=0.5, aspect=5)
print("Pintar")
plt.show()
