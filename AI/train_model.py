import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MultiLabelBinarizer, StandardScaler
from tensorflow import keras
import matplotlib.pyplot as plt
import json

df = pd.read_csv('simulated_orders.csv')


df['dish_names'] = df['dish_names'].apply(eval)
df['quantities'] = df['quantities'].apply(eval)

dish_quantities = []

for names, quantities in zip(df['dish_names'], df['quantities']):
    dish_list = []
    for name, q in zip(names, quantities):
        dish_list.extend([name] * q)
    dish_quantities.append(dish_list)

mlb = MultiLabelBinarizer()
X_dishes = mlb.fit_transform(dish_quantities)

y = df['total_time'].values

X_train, X_test, y_train, y_test = train_test_split(X_dishes, y, test_size=0.2, random_state=42)

model = keras.Sequential([
    keras.layers.Dense(64, activation='relu', input_shape=(X_train.shape[1],)),
    keras.layers.Dense(32, activation='relu'),
    keras.layers.Dense(1)
])

model.compile(optimizer='adam', loss='mse', metrics=['mae'])

history = model.fit(X_train, y_train, epochs=20, batch_size=32, validation_split=0.1)

loss, mae = model.evaluate(X_test, y_test)
print(f"MAE Test: {mae:.2f} minutes")

model.save('dish_time_predictor_model.keras')

with open("mlb_mapping.json", "w") as f:
    json.dump(mlb.classes_.tolist(), f)

plt.plot(history.history['mae'], label='MAE Entrenamiento')
plt.plot(history.history['val_mae'], label='MAE Validación')
plt.xlabel('Época')
plt.ylabel('MAE')
plt.legend()
plt.title('Error Absoluto Medio durante el Entrenamiento')
plt.grid(True)
plt.show()