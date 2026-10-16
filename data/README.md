# Datos

`data.csv` fue entregado por el docente del módulo de Análisis Predictivo del diplomado de la UPB. Contiene 10.000 registros de clientes y 18 columnas. No se conoce la fuente original ni el periodo de recopilación; por ello los resultados se limitan a este conjunto.

Cada fila representa un cliente. `Exited` indica abandono (`1`) o permanencia (`0`). El análisis agrupa clientes mediante `CreditScore`, `Balance`, `Age`, `Tenure` y `NumOfProducts`; `Exited` se utiliza solo después para describir los segmentos. Los identificadores y apellidos del archivo no se usan en el modelo.

| Campo | Significado en el análisis |
| --- | --- |
| `CreditScore` | Puntaje de crédito. |
| `Balance` | Saldo registrado. La moneda no está especificada. |
| `Age` | Edad. |
| `Tenure` | Antigüedad indicada en la base. Su unidad no está documentada. |
| `NumOfProducts` | Número de productos asociados al cliente. |
| `Exited` | Indicador binario de abandono. |

El CSV se conserva completo para permitir inspeccionar el contexto de las columnas. Las tasas calculadas aquí son descriptivas y no representan una estimación de abandono futuro.
