import pickle
import numpy as np
from keras.models import load_model

# Cargar el modelo entrenado
model = load_model("dish_time_predictor_model.keras")

# Cargar el MultiLabelBinarizer
with open("mlb.pkl", "rb") as f:
    mlb = pickle.load(f)

# Pedido inventado
new_order_names = ['Catalan Cream', 'Caesar salad']
new_order_quantities = [1, 3]

# Expandir platos según la cantidad
new_order_dishes = []
for name, qty in zip(new_order_names, new_order_quantities):
    new_order_dishes.extend([name] * qty)

print("Pedido expandido:", new_order_dishes)

# Transformar con mlb
X_new = mlb.transform([new_order_dishes])

# Hacer predicción
predicted_time = model.predict(X_new)
print(f"⏱️ Tiempo total predicho para el pedido: {predicted_time[0][0]:.2f} minutos")
