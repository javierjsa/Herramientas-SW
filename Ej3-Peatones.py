import cv2
import glob
import argparse



ap = argparse.ArgumentParser()
ap.add_argument("-i", "--images", required = False,
help = "ruta de las imagenes")

ap.add_argument("-o", "--out", required = False,
help = "video de salida")
args = vars(ap.parse_args())

path = args['images']



hog = cv2.HOGDescriptor()
hog.setSVMDetector(cv2.HOGDescriptor_getDefaultPeopleDetector())

for name in sorted(glob.glob('./images/*.png')):
    img=cv2.imread(name)
    print name
    rects, weights = hog.detectMultiScale(img, winStride=(8,8), padding=(32,32), scale=1.05)
    for rec in rects:
        cv2.rectangle(img,(rec[0],rec[1]),(rec[0]+rec[2],rec[1]+rec[3]),color=(255,0,0))
    print weights
    print "\n"
    cv2.imshow('peatones',img)
    cv2.waitKey(1)
