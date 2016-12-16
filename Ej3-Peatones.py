import cv2
import numpy as np
import glob
import argparse

ap = argparse.ArgumentParser()
ap.add_argument("-i", "--images", required = False,
help = "ruta de las imagenes")

ap.add_argument("-o", "--out", required = False,
help = "video de salida")
args = vars(ap.parse_args())

entrada = args['images']
out = args['out']

code = cv2.VideoWriter_fourcc(*'H264')
video=cv2.VideoWriter(out, fourcc=code, fps=24, frameSize=(640, 480), isColor=True)

hog = cv2.HOGDescriptor()
hog.setSVMDetector(cv2.HOGDescriptor_getDefaultPeopleDetector())
nombre = entrada + '/*.png'
color=np.array([(255, 0, 0), (0, 255, 0), (0, 0, 255), (0, 255, 255)])
for name in sorted(glob.glob(nombre)):
    img = cv2.imread(name)
    print name
    rects, weights = hog.detectMultiScale(img, winStride=(8,8), padding=(32,32), scale=1.05)
    i = 0
    for rec in rects:
        cv2.rectangle(img,(rec[0],rec[1]),(rec[0]+rec[2],rec[1]+rec[3]), color=color[i % 4], thickness=2)
        i += 1
    cv2.imshow('Peatones HOG', img)
    video.write(img)
    cv2.waitKey(1)

video.release()
cv2.destroyAllWindows()
