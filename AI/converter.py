import tensorflow as tf

# Cargar el modelo
model = tf.keras.models.load_model("dish_time_predictor_model.keras")

# Convertir a TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Guardar el modelo convertido
with open("dish_time_predictor_model.tflite", "wb") as f:
    f.write(tflite_model)
