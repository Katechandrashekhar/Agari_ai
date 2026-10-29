#!/usr/bin/env python
# -*- coding: utf-8 -*-

import tensorflow as tf
import numpy as np
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import os

# Define classes based on the labels file
classes = [
    'Apple_Black_Rot',
    'Apple_Healthy',
    'Corn_Common_Rust',
    'Corn_Gray_Leaf_Spot',
    'Corn_Healthy',
    'Potato_Early_Blight',
    'Potato_Healthy',
    'Potato_Late_Blight',
    'Rice_Bacterial_Leaf_Blight',
    'Rice_Brown_Spot',
    'Rice_Healthy',
    'Tomato_Early_Blight',
    'Tomato_Healthy',
    'Tomato_Late_Blight',
    'Tomato_Leaf_Mold',
    'Wheat_Brown_Rust',
    'Wheat_Healthy',
    'Wheat_Yellow_Rust'
]

num_classes = len(classes)

# Create a simple CNN model
model = Sequential([
    Conv2D(32, (3, 3), activation='relu', input_shape=(224, 224, 3)),
    MaxPooling2D((2, 2)),
    Conv2D(64, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Conv2D(128, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Conv2D(128, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Flatten(),
    Dense(512, activation='relu'),
    Dropout(0.5),
    Dense(num_classes, activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Create some random data for a simple model
# In a real scenario, this would be replaced with actual training data
x_train = np.random.random((100, 224, 224, 3))
y_train = np.random.random((100, num_classes))

# "Train" the model with random data (just for demonstration)
model.fit(x_train, y_train, epochs=1, batch_size=32, verbose=1)

# Convert the model to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the model to the assets directory
with open('e:/Agri/my_app/assets/models/crop_disease_model.tflite', 'wb') as f:
    f.write(tflite_model)

print("TFLite model created and saved to assets/models/crop_disease_model.tflite")