from sklearn.svm import LinearSVC
from hog import HOG
import dataset
import argparse
import cPickle
import cv2

ap = argparse.ArgumentParser()
ap.add_argument("-m", "--model", required=True,
                help="Ruta del modelo")
ap.add_argument("-i", "--image", required=True,
                help="imagen para deteccion")
args = vars(ap.parse_args())

#Leer y deserializar
f = open(args["model"], "rb")
model = cPickle.load(f)
f.close()

image = cv2.imread(args['image'])
gray = cv2.cvtColor(image,code=cv2.COLOR_BGR2GRAY)
gauss = cv2.GaussianBlur(gray,(5,5),0)

# Python: cv2.Canny(image, threshold1, threshold2[, edges[, apertureSize[, L2gradient]]])
canny = cv2.Canny(image=gauss,threshold1=750,threshold2=500,apertureSize=5)

cv2.imshow("cany",canny)
cv2.waitKey(0)

im2, contours, hierarchy = cv2.findContours(canny.copy(),cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

cv2.drawContours(image, contours, -1, (255,255,255), 1)


for cnt in contours:
    x, y, w, h = cv2.boundingRect(cnt)
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 1)

cv2.imshow("contornos",image)
cv2.waitKey(0)
