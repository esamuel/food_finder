# Food Recognition Model

## Model Requirements

To use the food recognition feature, you need to place a TensorFlow Lite model file named `food_model.tflite` in this directory.

## Recommended Models

You can use one of the following pre-trained models:

1. **MobileNet V2** - A lightweight model that works well for general image classification
   - Download from: https://www.tensorflow.org/lite/models/image_classification/overview

2. **EfficientNet** - Better accuracy but slightly larger model size
   - Download from: https://tfhub.dev/tensorflow/efficientnet/lite0/classification/2

3. **Food-101** - Specifically trained on food images
   - Download from: https://tfhub.dev/google/lite-model/aiy/vision/classifier/food_V1/1

## Converting Custom Models

If you have a custom food recognition model in TensorFlow format, you can convert it to TensorFlow Lite format using the TensorFlow Lite Converter:

```python
import tensorflow as tf

# Load your model
model = tf.keras.models.load_model('your_model.h5')

# Convert the model
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the model
with open('food_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

## Model Input/Output Specifications

The TFLite food recognition service expects the model to have the following specifications:

- **Input**: 224x224 RGB image (normalized to [0,1])
- **Output**: Array of class probabilities matching the labels in `food_labels.txt`

## Testing

After placing your model file in this directory, run the app and test the food recognition feature by taking a photo of food or selecting an image from your gallery. 