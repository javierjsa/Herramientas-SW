import numpy as np
import argparse
import math as m
import matplotlib.pyplot as plt

import plotly.plotly as py
def main():
  ap = argparse.ArgumentParser()
  ap.add_argument("-d", "--data", required=True,  help="ruta csv datos deteccion")
  ap.add_argument("-g", "--truth", required=True, help="ruta csv datos groundtruth")
  ap.add_argument("-o", "--out", required=True, help="ruta imagenes salida")
  args = vars(ap.parse_args())

  csv1 = args['data']
  csv2 = args['truth']
  out =  args['out']

  data = np.genfromtxt(csv1, delimiter=',', dtype=None, names=('Id', 'Area2D', 'Area3D', 'Complexity'))
  truth= np.genfromtxt(csv2, delimiter=',', dtype=None, names=('Id', 'Area2D', 'Area3D', 'Complexity'))

  data=data[1:280]
  truth=truth[1:280]

  data2d = [0]*7
  data3d = [0]*7
  dataCo = [0]*6

  for i in range(len(data)):
      [dId, dArea2D, dArea3D, dComplexity]=data[i]
      [tId, tArea2D, tArea3D, tComplexity] =truth[i]

      if dArea2D=='-' or tArea2D=='-':
          data2d[0]+=1
      else:
         val=abs(float(dArea2D)-float(tArea2D))
         if val>=250:
            data2d[6]+=1;
         else:
            data2d[int(m.floor(val/50)+1)] += 1
            #print("2D va=%f cat=%d\n" % (val, m.floor(val / 50) + 1))
      if dArea3D=='-' or tArea3D=='-':
          data3d[0] += 1
      else:
         val=abs(float(dArea3D)-float(tArea3D))
         if val>=250:
            data3d[6]+=1;
         else:
            data3d[int(m.floor(val/50)+1)] += 1
            #print("3D va=%f cat=%d\n" % (val,m.floor(val/50)+1))
      if dComplexity == '-' or tComplexity == '-':
          dataCo[0] +=1
      else:
          val = abs(float(dComplexity) - float(tComplexity))
          if val>=4:
            dataCo[5] += 1
          else:
            dataCo[int(m.floor(val)+1)]+=1
            #print("2D va=%f cat=%d\n" % (val, int(m.floor(val)+1)))


  total2d=float(sum(data2d));
  total3d=float(sum(data3d));
  totalCo=float(sum(dataCo));

  data2d[:] = [(float(x) / total2d)*100 for x in data2d];
  data3d[:] = [(float(x) / total3d)*100 for x in data3d];
  dataCo[:] = [(float(x) / totalCo)*100 for x in dataCo];



  plt.figure(1)
  ypos = range(len(data2d))
  ancho = 1/1.5
  g2d = plt.bar(ypos, data2d, ancho,align='center', color="red")
  plt.ylim(ymax=100, ymin=0)
  plt.title('Datos Area2D')
  etiq = ('Error', '[0-50)', '[50-100)', '[100-150)', '[150-200)', '[200-250)','>250')
  plt.xticks(ypos, etiq)
  g2d[0].set_color('k')
  str=out+'/Area2D.png'
  plt.savefig(str)

  plt.figure(2)
  ypos = range(len(data3d))
  ancho = 1/1.5
  g3d = plt.bar(ypos, data3d, ancho, align='center', color="red")
  plt.ylim(ymax=100, ymin=0)
  plt.title('Datos Area3D')
  plt.xticks(ypos, etiq)
  g3d[0].set_color('k')
  str = out + '/Area3D.png'
  plt.savefig(str)

  plt.figure(3)
  ypos = range(len(dataCo))
  ancho = 1 / 1.5
  etiqc = ('Error','0','1','2','3','>4')
  gc = plt.bar(ypos, dataCo, ancho, align='center', color="red")
  plt.ylim(ymax=100, ymin=0);
  plt.title('Datos Complejidad')
  plt.xticks(ypos, etiqc)
  gc[0].set_color('k')
  str = out + '/Complejidad.png';
  plt.savefig(str);
  plt.show()


if __name__ == '__main__':
    main()