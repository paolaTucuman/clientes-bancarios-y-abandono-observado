# Qué permite concluir este conjunto de datos

Este caso forma grupos de clientes y compara el abandono registrado en cada uno. La revisión del CSV también permite delimitar qué preguntas quedan abiertas. **No se estimó un efecto causal:** los datos disponibles no permiten identificarlo de forma defendible.

## Lo que sí se puede comprobar

Cada fila representa un cliente y `Exited` indica si abandonó (`1`) o permaneció (`0`). Con las 10.000 filas se pueden calcular tasas descriptivas. En los segmentos de este proyecto, abandonaron 1.305 de 5.804 clientes de saldo alto (22,48 %) y 733 de 4.196 de saldo bajo (17,47 %). La diferencia observada de 5,02 puntos porcentuales es una **asociación dentro de este archivo**; no mide el efecto de cambiar el saldo de una persona.

También sería posible explorar asociaciones con otras columnas y, si se verificara que fueron registradas antes del abandono, evaluar un modelo predictivo en datos reservados. Una predicción acertada no demostraría por qué ocurrió el abandono.

## Comprobaciones que impiden interpretar causas

| Comprobación | Evidencia en el CSV | Consecuencia |
| --- | --- | --- |
| Orden temporal | No hay columnas de fecha de medición ni de fecha de abandono. | No se sabe si saldo, actividad, satisfacción o reclamos precedieron a `Exited`. |
| Relación entre reclamo y abandono | `Complain` y `Exited` tienen el mismo valor en 9.986 de 10.000 filas. | La coincidencia exige verificar cuándo y cómo se registró `Complain`; no demuestra que reclamar cause abandono. |
| Comparación causal | No hay registro de una acción asignada a ciertos clientes, grupo de control, elegibilidad ni seguimiento posterior. | No es posible atribuir una diferencia de abandono a una intervención. |
| Contexto de recopilación | No se conoce el periodo ni la fuente original del conjunto entregado para el módulo. | No se puede asegurar que la asociación represente a clientes actuales de un banco. |

Además, los segmentos se formaron con cinco variables a la vez. Compararlos no aísla el efecto de `Balance`: edad, productos, actividad y factores no incluidos podrían relacionarse tanto con el saldo como con el abandono.

## Qué datos harían falta para investigar una causa

Primero habría que definir **una pregunta causal concreta**. Por ejemplo: «¿Ofrecer una medida de retención reduce el abandono durante los seis meses siguientes?». Para esa pregunta sería necesario registrar, como mínimo:

| Campo o información | Para qué serviría |
| --- | --- |
| `fecha_corte` y variables medidas antes de ella | Construir una situación inicial comparable sin incorporar información posterior. |
| `fecha_oferta`, `tipo_oferta` y clientes que la recibieron | Definir la intervención y cuándo ocurrió. |
| `elegible`, criterio de elegibilidad y grupo de comparación | Saber quién podía recibirla y contra quién se compara. |
| `fecha_abandono` o estado al terminar el seguimiento | Medir el mismo resultado en un periodo definido para ambos grupos. |
| Historial previo de saldo, productos, actividad, reclamos y otros factores relevantes | Evaluar diferencias iniciales que podrían explicar tanto la oferta como el abandono. |
| Regla de asignación de la oferta | Determinar si hubo asignación aleatoria o si hace falta justificar un diseño observacional. |

La lista cambia si se formula otra pregunta causal. **Añadir columnas no basta por sí solo:** se necesita un diseño que establezca el orden de los hechos y haga comparables los grupos. Una asignación aleatoria de la intervención daría evidencia más sólida; sin ella, un estudio observacional requeriría supuestos explícitos y análisis de sensibilidad.

## Alcance del proyecto

Este repositorio muestra segmentación y validación descriptiva del abandono. Sus resultados pueden orientar preguntas posteriores, pero **no atribuyen el abandono al saldo, a los reclamos ni a otra característica**.
