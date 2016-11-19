from sklearn.svm import LinearSVC
from hog import HOG
import dataset
import argparse
import cPickle
import cv2
import numpy as np

def main():

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
    canny = cv2.Canny(image=gauss,threshold1=500,threshold2=200,apertureSize=5)

    #cv2.imshow("cany",canny)
    #cv2.waitKey(0)
    #RETR_EXTERNAL cv2.RETR_TREE
    im2, contours, hierarchy = cv2.findContours(canny.copy(),cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)

    contours_sort=ordenarContornos(contours)
    contours_fus=fusionarContornos(contours_sort)
    #cv2.drawContours(image, contours, -1, (255,255,255), 1)


    for cnt in contours_fus:
        (x, y, w, h) = cnt
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 1)
    cv2.imshow("contornos",image)
    cv2.waitKey(0)


# Ordena los contornos pertenecientes a un fragmento de izquierda a derecha
def ordenarContornos(contours):
    lista = []
    lista.append(contours[0])

    aux = contours[1:]
    for cont in aux:
        x, y, w, h = cv2.boundingRect(cont)
        j = 0
        while j < len(lista):
            xt, yt, wt, ht = cv2.boundingRect(lista[j])
            if (x > xt):
                j = j + 1
            else:
                break

        if j < len(lista):
            lista.insert(j, cont)
        else:
            lista.append(cont)

    return lista

def fusionarContornos(contours):

    bbox=[]
    for cont in contours:
        rect = cv2.boundingRect(cont)
        bbox.append(rect)

    index_a = 0
    while (index_a<len(bbox)-1):
        index = index_a+1
        while index < len(bbox):

                x1, y1, w1, h1 = bbox[index_a]
                x2, y2, w2, h2 = bbox[index]

                ac = (x2 >= x1) & (x2 <= (x1+w1))
                bc = (y2 >= y1) & (y2 <= (y1+h1))
                cc = ((y2+h2) >= y1) & ((y2+h2) <= (y1+h1))

                if ac & (bc | cc):
                   x_aux=x2
                   y_aux=y2

                   if x1 < x2:
                       x_aux = x1
                   if y1<y2:
                       y_aux = y1

                   (x_op_2,y_op_2) = (x2+w2,y2+h2)
                   (x_op_1, y_op_1) = (x1 + w1, y1 + h1)

                   x_op_aux = x_op_2
                   y_op_aux = y_op_2

                   if x_op_1>x_op_2:
                       x_op_aux=x_op_1
                   if y_op_1>y_op_2:
                       y_op_aux=y_op_1

                   w_aux=x_op_aux-x_aux
                   h_aux=y_op_aux-y_aux

                   del bbox[index_a]
                   bbox.insert(index_a, (x_aux, y_aux, w_aux, h_aux))
                   del bbox[index]

                index += 1
        index_a += 1

    return bbox

if __name__ == "__main__":
    main()