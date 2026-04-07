# Proyecto de Base de datos SQL

Proyecto del módulo '5. SQL' para el **Máster en Data & Analytics** en **PowerMBA**.

## Estructura del Repositorio

El proyecto está organizado de la siguiente manera:

* `data/`: Carpeta donde se encuentra la base de datos `BBDD_Proyecto.sql` proporcionada para la realización del proyecto.
* `scripts/`: Carpeta donde se encuentra el archivo principal `LogicaConsultas.sql` con todas las soluciones identificadas por número y enunciado.
* `schema/`: Carpeta que contiene el esquema visual de la base de datos (ERD) `Diagram-MovieStore-public.png`.
* `README.md`: Este informe detallado.

---

## Análisis y Pasos Seguidos

### 1. Exploración del Esquema

Antes de realizar la primera consulta, se analizó el **Diagrama Entidad-Relación (ERD)** para identificar las claves primarias y foráneas. Esto permitió asegurar la integridad de los datos al realizar los `JOINs`.

### 2. Implementación de Consultas

El proceso de desarrollo se dividió en fases de complejidad ascendente:

* **Fase 1:** Extracción de métricas básicas sobre tablas maestras.
* **Fase 2:** Cruce de información. Se priorizó el uso de `INNER JOIN` para registros exactos y `LEFT/RIGHT JOIN` solo cuando la presencia de nulos era relevante para el análisis.
* **Fase 3:** Optimización. Para consultas que requerían cálculos intermedios, se utilizaron **CTEs** para mejorar la legibilidad frente a las subconsultas tradicionales.

### 3. Creación de Vistas

Se implementaron vistas para los reportes más solicitados, permitiendo que usuarios finales puedan consultar resultados complejos sin necesidad de reescribir la lógica de negocio.

---

## Buenas Prácticas Aplicadas

Para garantizar un código de calidad profesional, se han seguido estos principios:

1. **Indentación:** Uso de sangría consistente para separar cláusulas (`SELECT`, `FROM`, `WHERE`, `GROUP BY`).
2. **Naming Convention:** Uso de alias descriptivos para tablas y columnas.
3. **Comentarios:** Explicación detallada de la lógica en consultas complejas o filtros específicos.

---

## Conclusiones del Informe

Tras el análisis de la base de datos, se han obtenido los resultados solicitados, asegurando que cada fila devuelta tenga coherencia con el modelo de negocio planteado. El uso de estructuras temporales facilitó la limpieza de los datos antes de su presentación final.
