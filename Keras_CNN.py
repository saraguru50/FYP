import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
import numpy as np
import cv2
from imutils import paths
import matplotlib.pyplot as plt
from keras.preprocessing.image import img_to_array
from sklearn.preprocessing import LabelBinarizer
from sklearn.model_selection import train_test_split
import os
from google.colab import drive

drive.mount('/content/drive')

data = []
labels = []

imagePaths = sorted(list(paths.list_images("/content/drive/My Drive/Datasets")))
for imagePath in imagePaths:
  image = cv2.imread(imagePath)
  image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
  image = cv2.resize(image,(150, 320))
  image = img_to_array(image)
  data.append(image)
  label = imagePath.split(os.path.sep)[-2]
  labels.append(label)
  
#print(data)
#print(labels)

data = np.array(data, dtype="float") / 255.0
print(data.shape)
labels = np.array(labels)
lb = LabelBinarizer()
labels = lb.fit_transform(labels)
print(labels[0])
(x_train, x_test, y_train, y_test) = train_test_split(data,labels, test_size=0.2, random_state=42)

batch_size = 128
num_classes = 2
epochs = 2
img_rows, img_cols = 320, 150


#print('x_train shape:', x_train.shape)
#print(x_train.shape[0], 'train samples')
#print(x_test.shape[0], 'test samples')

#print('y_train shape:', y_train.shape)
#print(y_train.shape[0], 'train samples')
#print(y_test.shape[0], 'test samples')

#plt.imshow(x_train[0])
y_train = keras.utils.to_categorical(y_train, num_classes)
y_test = keras.utils.to_categorical(y_test, num_classes)

#print(y_train[0][1],"oblique")

model = Sequential()
model.add(Conv2D(32, kernel_size=(3, 3),
                 activation='relu',
                 input_shape=(320,150,1)))
model.add(Conv2D(64, (3, 3), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))
model.add(Flatten())
model.add(Dense(128, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(num_classes, activation='softmax'))

model.compile(loss=keras.losses.categorical_crossentropy,
              optimizer=keras.optimizers.Adadelta(),
              metrics=['accuracy'])

model.fit(x_train, y_train,
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          validation_data=(x_test, y_test))
score = model.evaluate(x_test, y_test, verbose=0)
print('Test loss:', score[0])
print('Test accuracy:', score[1])

