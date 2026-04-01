# 📡 DOCUMENTACIÓN API - IZY

## BASE URL

```
Desarrollo:  http://localhost:8000/api
Producción:  https://api.izy.com/api
```

## AUTENTICACIÓN

Todas las rutas protegidas requieren un token Bearer en el header:

```http
Authorization: Bearer {token}
```

---

## 1. AUTENTICACIÓN

### 1.1 Registro de Usuario

**Endpoint:** `POST /auth/register`

**Body:**
```json
{
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "phone": "+58412123456",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "cliente"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "phone": "+58412123456",
      "role": "cliente",
      "created_at": "2026-03-31T10:00:00.000000Z"
    },
    "token": "1|abc123...",
    "expires_in": 86400
  }
}
```

---

### 1.2 Login

**Endpoint:** `POST /auth/login`

**Body:**
```json
{
  "email": "juan@example.com",
  "password": "password123",
  "device_name": "iPhone 13"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "role": "cliente"
    },
    "token": "1|abc123...",
    "expires_in": 86400
  }
}
```

---

### 1.3 Logout

**Endpoint:** `POST /auth/logout`  
**Auth:** Required

**Response 200:**
```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

---

### 1.4 Usuario Actual

**Endpoint:** `GET /auth/me`  
**Auth:** Required

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "phone": "+58412123456",
    "role": "cliente",
    "avatar_url": null,
    "created_at": "2026-03-31T10:00:00.000000Z"
  }
}
```

---

## 2. COMERCIOS

### 2.1 Obtener Comercio por Slug

**Endpoint:** `GET /comercios/{slug}`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "slug": "pizzeria-express",
    "nombre": "Pizzería Express",
    "descripcion": "Las mejores pizzas de la ciudad",
    "categoria": "restaurante",
    "logo_url": "https://cdn.izy.com/logos/pizzeria-express.png",
    "banner_url": "https://cdn.izy.com/banners/pizzeria-express.jpg",
    "branding": {
      "colors": {
        "primary": "#FF5722",
        "secondary": "#FFC107"
      },
      "theme": "light"
    },
    "ubicacion": {
      "lat": 10.4806,
      "lng": -66.8037,
      "direccion": "Av. Principal de Los Ruices",
      "ciudad": "Caracas",
      "estado": "Miranda"
    },
    "contacto": {
      "telefono": "+58212123456",
      "email": "info@pizzeriaexpress.com",
      "whatsapp": "+58412123456"
    },
    "configuracion": {
      "radio_entrega_km": 5.0,
      "tiempo_preparacion_min": 30,
      "delivery_fee_usd": 2.0,
      "delivery_fee_bs": 70.0,
      "pedido_minimo_usd": 5.0,
      "pedido_minimo_bs": 175.0
    },
    "metodos_pago": {
      "efectivo": true,
      "pago_movil": true,
      "transferencia": false,
      "tarjeta": false
    },
    "horarios": {
      "lunes": {"open": "09:00", "close": "22:00", "closed": false},
      "martes": {"open": "09:00", "close": "22:00", "closed": false}
    },
    "is_active": true,
    "is_open": true,
    "rating": 4.8,
    "total_reviews": 150
  }
}
```

---

### 2.2 Comercios Cercanos

**Endpoint:** `GET /comercios/cercanos`

**Query Params:**
- `lat` (required): Latitud
- `lng` (required): Longitud
- `radio` (optional): Radio en km (default: 5)

**Example:** `/comercios/cercanos?lat=10.4806&lng=-66.8037&radio=3`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "slug": "pizzeria-express",
      "nombre": "Pizzería Express",
      "logo_url": "...",
      "categoria": "restaurante",
      "rating": 4.8,
      "distancia_km": 1.2,
      "tiempo_estimado_min": 35,
      "is_open": true
    }
  ]
}
```

---

## 3. PRODUCTOS

### 3.1 Listar Productos de Comercio

**Endpoint:** `GET /comercios/{slug}/productos`

**Query Params:**
- `categoria_id` (optional): Filtrar por categoría
- `search` (optional): Búsqueda por nombre
- `page` (optional): Página (default: 1)
- `per_page` (optional): Items por página (default: 20)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "Pizza Margarita",
      "descripcion": "Salsa de tomate, mozzarella y albahaca",
      "imagen_url": "https://cdn.izy.com/productos/pizza-margarita.jpg",
      "precio_usd": 8.50,
      "precio_bs": 301.75,
      "precio_oferta_usd": null,
      "precio_oferta_bs": null,
      "stock": 50,
      "stock_ilimitado": false,
      "tiene_variantes": true,
      "variantes": [
        {
          "name": "Tamaño",
          "required": true,
          "multiple": false,
          "options": [
            {"label": "Personal", "price_usd": 0, "price_bs": 0},
            {"label": "Mediana", "price_usd": 3, "price_bs": 106.5},
            {"label": "Familiar", "price_usd": 6, "price_bs": 213}
          ]
        }
      ],
      "is_active": true,
      "is_destacado": true,
      "categoria": {
        "id": 1,
        "nombre": "Pizzas"
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 25,
    "per_page": 20,
    "last_page": 2
  }
}
```

---

### 3.2 Detalle de Producto

**Endpoint:** `GET /productos/{id}`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nombre": "Pizza Margarita",
    "descripcion": "Salsa de tomate, mozzarella y albahaca fresca",
    "imagen_url": "https://cdn.izy.com/productos/pizza-margarita.jpg",
    "precio_usd": 8.50,
    "precio_bs": 301.75,
    "stock": 50,
    "tiene_variantes": true,
    "variantes": [...],
    "comercio": {
      "id": 1,
      "nombre": "Pizzería Express",
      "slug": "pizzeria-express"
    },
    "rating": 4.9,
    "total_ventas": 320
  }
}
```

---

## 4. PEDIDOS (CLIENTE)

### 4.1 Crear Pedido

**Endpoint:** `POST /pedidos`  
**Auth:** Required

**Body:**
```json
{
  "comercio_id": 1,
  "items": [
    {
      "producto_id": 1,
      "cantidad": 2,
      "variantes": [
        {
          "name": "Tamaño",
          "value": "Mediana",
          "price_usd": 3.0,
          "price_bs": 106.5
        }
      ],
      "notas": "Sin cebolla"
    }
  ],
  "tipo_pago": "efectivo",
  "vuelto_de": 1000.0,
  "direccion": {
    "calle": "Av. Principal, Edif. Torre, Piso 5",
    "ciudad": "Caracas",
    "estado": "Miranda",
    "referencia": "Torre azul al lado del C.C.",
    "lat": 10.4806,
    "lng": -66.8037
  },
  "notas_cliente": "Tocar el timbre 2 veces"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "numero_pedido": "IZY-20260331-0001",
    "token_seguimiento": "abc123def456...",
    "estado": "pendiente",
    "subtotal_usd": 23.0,
    "subtotal_bs": 816.5,
    "delivery_fee_usd": 2.0,
    "delivery_fee_bs": 70.0,
    "total_usd": 25.0,
    "total_bs": 886.5,
    "tipo_pago": "efectivo",
    "vuelto": 113.5,
    "tiempo_estimado_minutos": 30,
    "created_at": "2026-03-31T14:30:00.000000Z"
  },
  "message": "Pedido creado exitosamente"
}
```

---

### 4.2 Mis Pedidos

**Endpoint:** `GET /mis-pedidos`  
**Auth:** Required

**Query Params:**
- `estado` (optional): Filtrar por estado
- `page` (optional): Página

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "numero_pedido": "IZY-20260331-0001",
      "estado": "en_camino",
      "total_usd": 25.0,
      "total_bs": 886.5,
      "comercio": {
        "nombre": "Pizzería Express",
        "logo_url": "..."
      },
      "items_count": 2,
      "created_at": "2026-03-31T14:30:00.000000Z"
    }
  ]
}
```

---

### 4.3 Detalle de Pedido

**Endpoint:** `GET /pedidos/{id}`  
**Auth:** Required

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "numero_pedido": "IZY-20260331-0001",
    "estado": "en_camino",
    "items": [
      {
        "id": 1,
        "nombre_producto": "Pizza Margarita",
        "cantidad": 2,
        "precio_unitario_usd": 11.5,
        "precio_unitario_bs": 408.25,
        "subtotal_usd": 23.0,
        "subtotal_bs": 816.5,
        "variantes": [
          {
            "name": "Tamaño",
            "value": "Mediana"
          }
        ],
        "notas": "Sin cebolla"
      }
    ],
    "subtotal_usd": 23.0,
    "delivery_fee_usd": 2.0,
    "total_usd": 25.0,
    "tipo_pago": "efectivo",
    "vuelto": 113.5,
    "direccion": {
      "calle": "Av. Principal, Edif. Torre, Piso 5",
      "referencia": "Torre azul al lado del C.C.",
      "lat": 10.4806,
      "lng": -66.8037
    },
    "comercio": {
      "nombre": "Pizzería Express",
      "telefono": "+58212123456"
    },
    "repartidor": {
      "nombre": "Carlos Ramos",
      "telefono": "+58412345678",
      "vehiculo": "moto",
      "placa": "ABC123"
    },
    "historial_estados": [
      {
        "estado": "pendiente",
        "fecha": "2026-03-31T14:30:00.000000Z"
      },
      {
        "estado": "confirmado",
        "fecha": "2026-03-31T14:32:00.000000Z"
      },
      {
        "estado": "preparando",
        "fecha": "2026-03-31T14:35:00.000000Z"
      },
      {
        "estado": "listo",
        "fecha": "2026-03-31T14:50:00.000000Z"
      },
      {
        "estado": "en_camino",
        "fecha": "2026-03-31T14:55:00.000000Z"
      }
    ],
    "created_at": "2026-03-31T14:30:00.000000Z"
  }
}
```

---

### 4.4 Tracking Público

**Endpoint:** `GET /pedidos/{token}/tracking`  
**Auth:** No requerida

**Response 200:**
```json
{
  "success": true,
  "data": {
    "numero_pedido": "IZY-20260331-0001",
    "estado": "en_camino",
    "tiempo_estimado_minutos": 15,
    "comercio": {
      "nombre": "Pizzería Express",
      "lat": 10.4806,
      "lng": -66.8037
    },
    "cliente": {
      "lat": 10.4850,
      "lng": -66.8100
    },
    "repartidor": {
      "nombre": "Carlos",
      "lat": 10.4820,
      "lng": -66.8050,
      "last_update": "2026-03-31T15:05:00.000000Z"
    }
  }
}
```

---

### 4.5 Cancelar Pedido

**Endpoint:** `PUT /pedidos/{id}/cancel`  
**Auth:** Required

**Body:**
```json
{
  "razon": "Cambié de opinión"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Pedido cancelado exitosamente"
}
```

---

## 5. PEDIDOS (COMERCIO)

### 5.1 Listar Pedidos del Comercio

**Endpoint:** `GET /comercio/pedidos`  
**Auth:** Required (role: comercio)

**Query Params:**
- `estado` (optional): pendiente, confirmado, preparando, listo, en_camino, entregado
- `fecha_desde` (optional): YYYY-MM-DD
- `fecha_hasta` (optional): YYYY-MM-DD

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "numero_pedido": "IZY-20260331-0001",
      "estado": "preparando",
      "cliente": {
        "nombre": "Juan Pérez",
        "telefono": "+58412123456"
      },
      "items_count": 2,
      "total_usd": 25.0,
      "tipo_pago": "efectivo",
      "tiempo_transcurrido_minutos": 15,
      "created_at": "2026-03-31T14:30:00.000000Z"
    }
  ]
}
```

---

### 5.2 Actualizar Estado de Pedido

**Endpoint:** `PUT /comercio/pedidos/{id}/estado`  
**Auth:** Required (role: comercio)

**Body:**
```json
{
  "estado": "preparando",
  "notas": "Iniciando preparación"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "estado": "preparando",
    "updated_at": "2026-03-31T14:35:00.000000Z"
  },
  "message": "Estado actualizado exitosamente"
}
```

---

### 5.3 Asignar Repartidor

**Endpoint:** `POST /comercio/pedidos/{id}/asignar-repartidor`  
**Auth:** Required (role: comercio)

**Body (Asignación Manual):**
```json
{
  "repartidor_id": 5,
  "tipo": "manual"
}
```

**Body (Solicitar Freelance):**
```json
{
  "tipo": "freelance",
  "radio_km": 3
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "pedido_id": 1,
    "repartidor": {
      "id": 5,
      "nombre": "Carlos Ramos",
      "telefono": "+58412345678"
    },
    "tipo_asignacion": "manual"
  },
  "message": "Repartidor asignado exitosamente"
}
```

---

### 5.4 Estadísticas del Comercio

**Endpoint:** `GET /comercio/estadisticas`  
**Auth:** Required (role: comercio)

**Query Params:**
- `periodo` (optional): hoy, semana, mes (default: hoy)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "ventas": {
      "total_usd": 450.50,
      "total_bs": 15992.75,
      "total_pedidos": 18,
      "pedidos_completados": 15,
      "pedidos_cancelados": 1,
      "ticket_promedio_usd": 25.03
    },
    "productos_mas_vendidos": [
      {
        "producto": "Pizza Margarita",
        "cantidad": 25,
        "total_usd": 212.50
      }
    ],
    "grafico_ventas": [
      {
        "fecha": "2026-03-31",
        "total_usd": 450.50,
        "pedidos": 18
      }
    ]
  }
}
```

---

## 6. REPARTIDOR

### 6.1 Pedidos Disponibles (Freelance)

**Endpoint:** `GET /repartidor/pedidos/disponibles`  
**Auth:** Required (role: repartidor)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "numero_pedido": "IZY-20260331-0001",
      "comercio": {
        "nombre": "Pizzería Express",
        "direccion": "Av. Principal de Los Ruices",
        "lat": 10.4806,
        "lng": -66.8037
      },
      "cliente": {
        "direccion": "Av. Francisco de Miranda",
        "lat": 10.4850,
        "lng": -66.8100
      },
      "distancia_total_km": 2.5,
      "ganancia_estimada_usd": 3.0,
      "tipo_pago": "efectivo",
      "monto_cobrar_bs": 886.5,
      "tiempo_expiracion": "2026-03-31T15:00:00.000000Z"
    }
  ]
}
```

---

### 6.2 Aceptar Pedido

**Endpoint:** `POST /repartidor/pedidos/{id}/aceptar`  
**Auth:** Required (role: repartidor)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "pedido_id": 1,
    "estado": "asignado",
    "comercio": {
      "nombre": "Pizzería Express",
      "direccion": "Av. Principal de Los Ruices",
      "telefono": "+58212123456",
      "lat": 10.4806,
      "lng": -66.8037
    }
  },
  "message": "Pedido aceptado exitosamente"
}
```

---

### 6.3 Rechazar Pedido

**Endpoint:** `POST /repartidor/pedidos/{id}/rechazar`  
**Auth:** Required (role: repartidor)

**Body:**
```json
{
  "razon": "Muy lejos"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Pedido rechazado"
}
```

---

### 6.4 Actualizar Ubicación

**Endpoint:** `POST /repartidor/ubicacion`  
**Auth:** Required (role: repartidor)

**Body:**
```json
{
  "lat": 10.4820,
  "lng": -66.8050,
  "accuracy": 10.5,
  "speed": 5.2,
  "pedido_id": 1
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Ubicación actualizada"
}
```

---

### 6.5 Confirmar Recogida

**Endpoint:** `POST /repartidor/pedidos/{id}/confirmar-recogida`  
**Auth:** Required (role: repartidor)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "pedido_id": 1,
    "estado": "en_camino",
    "cliente": {
      "nombre": "Juan Pérez",
      "telefono": "+58412123456",
      "direccion": "Av. Francisco de Miranda",
      "referencia": "Torre azul",
      "lat": 10.4850,
      "lng": -66.8100
    }
  },
  "message": "Recogida confirmada"
}
```

---

### 6.6 Confirmar Entrega

**Endpoint:** `POST /repartidor/pedidos/{id}/confirmar-entrega`  
**Auth:** Required (role: repartidor)

**Body:**
```json
{
  "cobro_confirmado": true,
  "monto_cobrado_bs": 886.5,
  "firma_url": "https://cdn.izy.com/firmas/pedido-1.png",
  "foto_comprobante_url": "https://cdn.izy.com/comprobantes/pedido-1.jpg"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "pedido_id": 1,
    "estado": "entregado",
    "ganancia_usd": 3.0,
    "ganancia_bs": 106.5
  },
  "message": "Entrega confirmada exitosamente"
}
```

---

### 6.7 Estadísticas del Repartidor

**Endpoint:** `GET /repartidor/estadisticas`  
**Auth:** Required (role: repartidor)

**Query Params:**
- `periodo` (optional): hoy, semana, mes

**Response 200:**
```json
{
  "success": true,
  "data": {
    "ganancias": {
      "hoy_usd": 45.0,
      "hoy_bs": 1597.5,
      "semana_usd": 280.0,
      "mes_usd": 1200.0
    },
    "entregas": {
      "hoy": 15,
      "semana": 95,
      "mes": 380,
      "total": 1250
    },
    "rating": 4.8,
    "tasa_aceptacion": 85.5
  }
}
```

---

## 7. DIRECCIONES

### 7.1 Listar Direcciones

**Endpoint:** `GET /direcciones`  
**Auth:** Required

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "alias": "Casa",
      "calle": "Av. Principal, Edif. Torre, Piso 5",
      "ciudad": "Caracas",
      "referencia": "Torre azul",
      "lat": 10.4806,
      "lng": -66.8037,
      "is_default": true
    }
  ]
}
```

---

### 7.2 Crear Dirección

**Endpoint:** `POST /direcciones`  
**Auth:** Required

**Body:**
```json
{
  "alias": "Oficina",
  "calle": "Av. Francisco de Miranda, Torre Banaven",
  "ciudad": "Caracas",
  "estado": "Miranda",
  "referencia": "Piso 10, oficina 1005",
  "lat": 10.4850,
  "lng": -66.8100,
  "is_default": false
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "alias": "Oficina",
    "calle": "Av. Francisco de Miranda, Torre Banaven",
    "lat": 10.4850,
    "lng": -66.8100
  },
  "message": "Dirección creada exitosamente"
}
```

---

## 8. CONFIGURACIÓN

### 8.1 Actualizar FCM Token

**Endpoint:** `POST /user/fcm-token`  
**Auth:** Required

**Body:**
```json
{
  "fcm_token": "dGhpcyBpcyBhIGZha2UgdG9rZW4..."
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Token actualizado"
}
```

---

### 8.2 Obtener Tasa de Cambio

**Endpoint:** `GET /configuracion/tasa-cambio`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "tasa_usd_bs": 35.50,
    "fecha_actualizacion": "2026-03-31T08:00:00.000000Z"
  }
}
```

---

## CÓDIGOS DE ERROR

| Código | Descripción |
|--------|-------------|
| 400 | Bad Request - Datos inválidos |
| 401 | Unauthorized - No autenticado |
| 403 | Forbidden - Sin permisos |
| 404 | Not Found - Recurso no encontrado |
| 422 | Unprocessable Entity - Validación fallida |
| 429 | Too Many Requests - Rate limit excedido |
| 500 | Internal Server Error - Error del servidor |

## FORMATO DE ERRORES

```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "email": ["El email ya está registrado"],
    "password": ["La contraseña debe tener al menos 8 caracteres"]
  }
}
```

## RATE LIMITING

- **Login/Register:** 5 requests/minuto por IP
- **API General:** 120 requests/minuto por usuario
- **Ubicación GPS:** 300 requests/minuto por repartidor
