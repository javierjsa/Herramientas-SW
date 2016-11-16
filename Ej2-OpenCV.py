import cv2
import argparse
import numpy as np
# Javier Saez Alonso


ap = argparse.ArgumentParser()
ap.add_argument("-v", "--video", required = False,
help = "ruta del video de origen")
ap.add_argument("-o", "--out", required = False,
help = "ruta del video de destino")
args = vars(ap.parse_args())



origen = args['video']
destino =args['out']

cap = cv2.VideoCapture(origen)

ret, frame = cap.read()
shape= np.shape(frame)
print shape
code = cv2.VideoWriter_fourcc(*'H264')
out = cv2.VideoWriter(destino, fourcc=code, fps=24.0, frameSize=(shape[0], shape[1]))

#el detector de ojos solamente recibe las regiones donde se ha detectado una cara
faceCascade = cv2.CascadeClassifier("./haarcascade_frontalface_default.xml")
eyeCascade = cv2.CascadeClassifier("./haarcascade_eye.xml")

#tamano minimo cara
(mina,minb)=int(round(shape[1]*0.02)), int(round(shape[2]*0.02))

#tamano minimo ojos
(minc,mind)=int(round(shape[1]*0.002)), int(round(shape[2]*0.002))
watchdog=0
while(cap.isOpened() & watchdog<100):

  gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
  rectangulos = faceCascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=20, minSize=(mina,minb))
  i=0
  while(i<len(rectangulos)):
    rects=rectangulos[i]
    cv2.rectangle(frame, (rects[0],rects[1]), (rects[0]+rects[2],rects[1]+rects[3]), (0, 255, 0), 1)
    roi=gray[rects[1]:rects[1]+rects[3],rects[0]:rects[0]+rects[2]]
    ojos = eyeCascade.detectMultiScale(roi, scaleFactor=1.1, minNeighbors=15, minSize=(minc,mind), flags = cv2.CASCADE_SCALE_IMAGE)
    j=0
    while(j<len(ojos)):
      rects_2=ojos[j]
      cv2.rectangle(frame,(rects[0]+rects_2[0],rects[1]+rects_2[1]), (rects[0]+rects_2[0]+rects_2[2],rects[1]+rects_2[1]+rects_2[3]),(0, 0, 255), 1)
      j=j+1
    i=i+1
  cv2.imshow('frame',frame)
  if cv2.waitKey(20) & 0xFF == ord('q'):
    break

  out.write(frame)

  ret, frame = cap.read()
  if ret == False:
      print("No se pueden recuperar mas frames")
      break
out.release()
cap.release()
cv2.destroyAllWindows()
