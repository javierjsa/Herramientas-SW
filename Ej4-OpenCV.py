import cv2
import argparse
import glob



ap = argparse.ArgumentParser()
ap.add_argument("-q", "--query", required = False, help = "imagen consultada")
ap.add_argument("-c", "--covers", required = False, help = "imagenes a comparar")

args = vars(ap.parse_args())

imagen = args['query']
compara = args['covers']

compara = compara+ '*'
list = glob.glob(compara)


image = cv2.imread(imagen,1)
img1 = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY )
orb = cv2.ORB_create()
bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
kp1, des1 = orb.detectAndCompute(img1, None)

keypoints = []
for name in list:
    img_comp = cv2.imread(name,1)
    img2 = cv2.cvtColor(img_comp, cv2.COLOR_RGB2GRAY)
    kp2, des2 = orb.detectAndCompute(img2,None)
    matches = bf.match(des1,des2)
    if len(matches) > 50:
        keypoints.append((name, len(matches)))

keypoints.sort()

name, points = keypoints[0]
print name
print points
img=cv2.imread(name)
img=cv2.resize(img,fx=0.5,fy=0.5,dsize=(0,0),interpolation=cv2.INTER_CUBIC)
cv2.imshow("Resultado",img)
cv2.waitKey(0)
cv2.destroyAllWindows()

