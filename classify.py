from sklearn.svm import LinearSVC
from hog import HOG
import dataset as dt
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

    #convertir a b/w y blur
    image = cv2.imread(args['image'])
    gray = cv2.cvtColor(image,code=cv2.COLOR_BGR2GRAY)
    gauss = cv2.GaussianBlur(gray,(5,5),0)

    #canny y deteccion de contornos
    canny = cv2.Canny(image=gauss,threshold1=500,threshold2=200,apertureSize=5)
    im2, contours, hierarchy = cv2.findContours(canny.copy(),cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)

    #ordenar y fusionar contornos
    contours_sort = ordenarContornos(contours)
    contours_fus = fusionarContornos(contours_sort)

    #pinta bounding boxes
    for cnt in contours_fus:
        (x, y, w, h) = cnt
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 1)

    #genera los descriptores
    histogramas=procesar(gray,contours_fus)

    #realiza la prediccion
    for hist,cnt in zip(histogramas,contours_fus):
        (x, y, w, h) = cnt
        digit = model.predict(hist)[0]
        cv2.putText(image, str(digit), (x,y-1), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0), 2)

    #mostrar resultados
    cv2.imshow("digitos", image)
    cv2.waitKey()


# Ordena los contornos de izquierda a derecha
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

#fusiona contornos solapados, evita dividir un digito cuando hay discontinuidad en el trazo
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
                else:
                    index += 1
        index_a += 1

    return bbox

def procesar(imagen,contornos):
    hog = HOG(orientations=18, pixelsPerCell=(10, 10),
              cellsPerBlock=(1, 1), normalize=True)
    hogs=[]
    for cnt in contornos:
        x,y,w,h= cnt
        roi=imagen[y:y+h,x:x+w]
        ret2, th2 = cv2.threshold(roi, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
        binary_img = roi > th2  # tipo bool
        inv= 255-(binary_img.astype(np.uint8)*255)
        deskew = dt.deskew(inv,20)
        centered = dt.center_extent(deskew, (20, 20))
        hist = hog.describe(centered)
        hogs.append(hist)
        cv2.destroyAllWindows()
    return hogs
if __name__ == "__main__":
    main()