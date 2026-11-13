--
-- PostgreSQL database dump
--

\restrict Iw0IyfPIzbj43qrn0SxO9TszFccPK5y71Yx01dWU0cFatpUlXeICcFV406smncS

-- Dumped from database version 17.11
-- Dumped by pg_dump version 18.4

-- Started on 2026-11-12 21:47:25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 24998)
-- Name: vanabbyDB; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "vanabbyDB";


ALTER SCHEMA "vanabbyDB" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 26281)
-- Name: agenda; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".agenda (
    agenda_id integer NOT NULL,
    venta_id integer,
    fecha_programada timestamp without time zone,
    responsable_empleado_id integer,
    estado_agenda_id integer,
    notas text
);


ALTER TABLE "vanabbyDB".agenda OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 26286)
-- Name: anticipo; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".anticipo (
    anticipo_id integer NOT NULL,
    venta_id integer,
    cliente_id integer,
    monto_anticipo numeric(12,2) NOT NULL,
    monto_restante numeric(12,2) NOT NULL,
    fecha_registro timestamp without time zone NOT NULL,
    fecha_limite timestamp without time zone,
    estado_anticipo_id integer,
    metodo_pago_id integer
);


ALTER TABLE "vanabbyDB".anticipo OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 26289)
-- Name: bloqueo; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".bloqueo (
    bloqueo_id integer NOT NULL,
    empleado_id integer,
    cliente_id integer,
    fecha_bloqueo timestamp without time zone,
    intentos_acumulados integer NOT NULL,
    desbloqueado_por_empleado_id integer,
    fecha_desbloqueo timestamp without time zone,
    motivo text
);


ALTER TABLE "vanabbyDB".bloqueo OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 26294)
-- Name: categoria; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".categoria (
    categoria_id integer NOT NULL,
    nombre_categoria character varying(80) NOT NULL
);


ALTER TABLE "vanabbyDB".categoria OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 26297)
-- Name: cliente; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".cliente (
    cliente_id integer NOT NULL,
    nombre character varying(80) NOT NULL,
    ap_paterno character varying(60),
    ap_materno character varying(60),
    telefono character varying(20),
    correo character varying(120),
    creado_en timestamp without time zone
);


ALTER TABLE "vanabbyDB".cliente OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 26300)
-- Name: compra; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".compra (
    compra_id integer NOT NULL,
    proveedor_id integer,
    creado_en timestamp without time zone,
    fecha_esperada date,
    estado_compra_id integer
);


ALTER TABLE "vanabbyDB".compra OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 26303)
-- Name: detalle_compra; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".detalle_compra (
    detalle_compra_id integer NOT NULL,
    compra_id integer,
    ingrediente_id integer,
    cantidad numeric(12,4) NOT NULL,
    precio_unitario numeric(12,6) NOT NULL,
    subtotal numeric(12,2) NOT NULL
);


ALTER TABLE "vanabbyDB".detalle_compra OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 26306)
-- Name: detalle_venta; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".detalle_venta (
    detalle_venta_id integer NOT NULL,
    venta_id integer,
    producto_id integer,
    cantidad integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    subtotal numeric(12,2) NOT NULL
);


ALTER TABLE "vanabbyDB".detalle_venta OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 26309)
-- Name: direccion_cliente; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".direccion_cliente (
    direccion_id integer NOT NULL,
    cliente_id integer NOT NULL,
    alias character varying(40),
    calle character varying(150),
    numero character varying(20),
    colonia character varying(100),
    ciudad character varying(80),
    estado_geo character varying(80),
    cp character varying(10),
    es_principal smallint
);


ALTER TABLE "vanabbyDB".direccion_cliente OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 26312)
-- Name: direccion_empleado; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".direccion_empleado (
    direccion_id integer NOT NULL,
    empleado_id integer NOT NULL,
    alias character varying(40),
    calle character varying(150),
    numero character varying(20),
    colonia character varying(100),
    ciudad character varying(80),
    estado_geo character varying(80),
    cp character varying(10),
    es_principal smallint
);


ALTER TABLE "vanabbyDB".direccion_empleado OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 26315)
-- Name: direccion_proveedor; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".direccion_proveedor (
    direccion_id integer NOT NULL,
    proveedor_id integer NOT NULL,
    alias character varying(40),
    calle character varying(150),
    numero character varying(20),
    colonia character varying(100),
    ciudad character varying(80),
    estado_geo character varying(80),
    cp character varying(10),
    es_principal smallint
);


ALTER TABLE "vanabbyDB".direccion_proveedor OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 26318)
-- Name: empleado; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".empleado (
    empleado_id integer NOT NULL,
    nombre_usuario character varying(80) NOT NULL,
    clave_hash character varying(255) NOT NULL,
    nombre character varying(80),
    ap_paterno character varying(60),
    ap_materno character varying(60),
    rol_id integer,
    bloqueado smallint,
    intentos_fallidos integer,
    ultimo_intento timestamp without time zone,
    creado_en timestamp without time zone
);


ALTER TABLE "vanabbyDB".empleado OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 26323)
-- Name: envio; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".envio (
    envio_id integer NOT NULL,
    pedido_id integer NOT NULL,
    direccion_id integer NOT NULL,
    empleado_id integer,
    costo_envio numeric(12,2),
    fecha_salida timestamp without time zone,
    fecha_entrega_real timestamp without time zone,
    notas text
);


ALTER TABLE "vanabbyDB".envio OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 26328)
-- Name: estado_agenda; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".estado_agenda (
    estado_agenda_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE "vanabbyDB".estado_agenda OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 26331)
-- Name: estado_anticipo; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".estado_anticipo (
    estado_anticipo_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE "vanabbyDB".estado_anticipo OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 26334)
-- Name: estado_compra; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".estado_compra (
    estado_compra_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE "vanabbyDB".estado_compra OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 26337)
-- Name: estado_pedido; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".estado_pedido (
    estado_pedido_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE "vanabbyDB".estado_pedido OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 26340)
-- Name: estado_venta; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".estado_venta (
    estado_venta_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE "vanabbyDB".estado_venta OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 26343)
-- Name: ingrediente; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".ingrediente (
    ingrediente_id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    unidad_medida_id integer NOT NULL,
    costo_por_unidad numeric(12,6)
);


ALTER TABLE "vanabbyDB".ingrediente OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 26346)
-- Name: inventario_producto; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".inventario_producto (
    inv_producto_id integer NOT NULL,
    producto_id integer NOT NULL,
    stock_disponible integer NOT NULL,
    stock_minimo integer NOT NULL,
    actualizado_en timestamp without time zone
);


ALTER TABLE "vanabbyDB".inventario_producto OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 26349)
-- Name: lote_inventario; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".lote_inventario (
    lote_id integer NOT NULL,
    ingrediente_id integer,
    numero_lote character varying(50),
    cantidad numeric(12,4),
    unidad_medida_id integer,
    fecha_caducidad date,
    creado_en timestamp without time zone
);


ALTER TABLE "vanabbyDB".lote_inventario OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 26352)
-- Name: metodo_pago; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".metodo_pago (
    metodo_pago_id integer NOT NULL,
    nombre_metodo character varying(50) NOT NULL
);


ALTER TABLE "vanabbyDB".metodo_pago OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 26355)
-- Name: pago_venta; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".pago_venta (
    pago_venta_id integer NOT NULL,
    venta_id integer,
    metodo_pago_id integer,
    monto numeric(12,2) NOT NULL,
    pagado_en timestamp without time zone,
    registrado_por integer
);


ALTER TABLE "vanabbyDB".pago_venta OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 26358)
-- Name: paso_receta; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".paso_receta (
    paso_id integer NOT NULL,
    receta_id integer,
    numero_paso integer,
    descripcion character varying(255)
);


ALTER TABLE "vanabbyDB".paso_receta OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 26361)
-- Name: pedido; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".pedido (
    pedido_id integer NOT NULL,
    cliente_id integer NOT NULL,
    empleado_id integer NOT NULL,
    estado_pedido_id integer NOT NULL,
    prioridad_id integer NOT NULL,
    fecha_pedido timestamp without time zone NOT NULL,
    fecha_entrega_programada timestamp without time zone
);


ALTER TABLE "vanabbyDB".pedido OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 26364)
-- Name: permiso; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".permiso (
    permiso_id integer NOT NULL,
    nombre_permiso character varying(100) NOT NULL,
    descripcion text
);


ALTER TABLE "vanabbyDB".permiso OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 26369)
-- Name: prioridad; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".prioridad (
    prioridad_id integer NOT NULL,
    nombre_prioridad character varying(50) NOT NULL
);


ALTER TABLE "vanabbyDB".prioridad OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 26372)
-- Name: producto; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".producto (
    producto_id integer NOT NULL,
    sku character varying(30) NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    imagen character varying(255),
    categoria_id integer,
    precio numeric(10,2) NOT NULL,
    tiempo_preparacion_min integer,
    creado_en timestamp without time zone
);


ALTER TABLE "vanabbyDB".producto OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 26377)
-- Name: proveedor; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".proveedor (
    proveedor_id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    contacto_nombre character varying(80),
    contacto_ap_paterno character varying(60),
    contacto_ap_materno character varying(60),
    telefono character varying(40),
    correo character varying(120),
    notas text
);


ALTER TABLE "vanabbyDB".proveedor OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 26382)
-- Name: receta; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".receta (
    receta_id integer NOT NULL,
    producto_id integer,
    rendimiento integer,
    tiempo_estimado_min integer
);


ALTER TABLE "vanabbyDB".receta OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 26385)
-- Name: receta_ingrediente; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".receta_ingrediente (
    receta_id integer NOT NULL,
    ingrediente_id integer NOT NULL,
    cantidad numeric(12,4)
);


ALTER TABLE "vanabbyDB".receta_ingrediente OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 26388)
-- Name: rol; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".rol (
    rol_id integer NOT NULL,
    nombre_rol character varying(50) NOT NULL,
    descripcion text
);


ALTER TABLE "vanabbyDB".rol OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 26393)
-- Name: rol_permiso; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".rol_permiso (
    rol_id integer NOT NULL,
    permiso_id integer NOT NULL
);


ALTER TABLE "vanabbyDB".rol_permiso OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 26396)
-- Name: unidad_medida; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".unidad_medida (
    unidad_medida_id integer NOT NULL,
    simbolo character varying(10) NOT NULL,
    descripcion character varying(60)
);


ALTER TABLE "vanabbyDB".unidad_medida OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 26399)
-- Name: venta; Type: TABLE; Schema: vanabbyDB; Owner: postgres
--

CREATE TABLE "vanabbyDB".venta (
    venta_id integer NOT NULL,
    empleado_id integer,
    cliente_id integer,
    metodo_pago_id integer,
    estado_venta_id integer,
    pedido_id integer,
    fecha_venta timestamp without time zone NOT NULL,
    fecha_entrega_programada timestamp without time zone,
    total numeric(12,2) NOT NULL
);


ALTER TABLE "vanabbyDB".venta OWNER TO postgres;

--
-- TOC entry 4879 (class 2606 OID 26403)
-- Name: agenda agenda_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (agenda_id);


--
-- TOC entry 4881 (class 2606 OID 26405)
-- Name: anticipo anticipo_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".anticipo
    ADD CONSTRAINT anticipo_pkey PRIMARY KEY (anticipo_id);


--
-- TOC entry 4883 (class 2606 OID 26407)
-- Name: bloqueo bloqueo_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".bloqueo
    ADD CONSTRAINT bloqueo_pkey PRIMARY KEY (bloqueo_id);


--
-- TOC entry 4885 (class 2606 OID 26409)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (categoria_id);


--
-- TOC entry 4887 (class 2606 OID 26411)
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (cliente_id);


--
-- TOC entry 4889 (class 2606 OID 26413)
-- Name: compra compra_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".compra
    ADD CONSTRAINT compra_pkey PRIMARY KEY (compra_id);


--
-- TOC entry 4891 (class 2606 OID 26415)
-- Name: detalle_compra detalle_compra_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".detalle_compra
    ADD CONSTRAINT detalle_compra_pkey PRIMARY KEY (detalle_compra_id);


--
-- TOC entry 4893 (class 2606 OID 26417)
-- Name: detalle_venta detalle_venta_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".detalle_venta
    ADD CONSTRAINT detalle_venta_pkey PRIMARY KEY (detalle_venta_id);


--
-- TOC entry 4895 (class 2606 OID 26419)
-- Name: direccion_cliente direccion_cliente_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".direccion_cliente
    ADD CONSTRAINT direccion_cliente_pkey PRIMARY KEY (direccion_id);


--
-- TOC entry 4897 (class 2606 OID 26421)
-- Name: direccion_empleado direccion_empleado_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".direccion_empleado
    ADD CONSTRAINT direccion_empleado_pkey PRIMARY KEY (direccion_id);


--
-- TOC entry 4899 (class 2606 OID 26423)
-- Name: direccion_proveedor direccion_proveedor_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".direccion_proveedor
    ADD CONSTRAINT direccion_proveedor_pkey PRIMARY KEY (direccion_id);


--
-- TOC entry 4901 (class 2606 OID 26425)
-- Name: empleado empleado_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (empleado_id);


--
-- TOC entry 4903 (class 2606 OID 26427)
-- Name: envio envio_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".envio
    ADD CONSTRAINT envio_pkey PRIMARY KEY (envio_id);


--
-- TOC entry 4905 (class 2606 OID 26429)
-- Name: estado_agenda estado_agenda_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".estado_agenda
    ADD CONSTRAINT estado_agenda_pkey PRIMARY KEY (estado_agenda_id);


--
-- TOC entry 4907 (class 2606 OID 26431)
-- Name: estado_anticipo estado_anticipo_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".estado_anticipo
    ADD CONSTRAINT estado_anticipo_pkey PRIMARY KEY (estado_anticipo_id);


--
-- TOC entry 4909 (class 2606 OID 26433)
-- Name: estado_compra estado_compra_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".estado_compra
    ADD CONSTRAINT estado_compra_pkey PRIMARY KEY (estado_compra_id);


--
-- TOC entry 4911 (class 2606 OID 26435)
-- Name: estado_pedido estado_pedido_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".estado_pedido
    ADD CONSTRAINT estado_pedido_pkey PRIMARY KEY (estado_pedido_id);


--
-- TOC entry 4913 (class 2606 OID 26437)
-- Name: estado_venta estado_venta_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".estado_venta
    ADD CONSTRAINT estado_venta_pkey PRIMARY KEY (estado_venta_id);


--
-- TOC entry 4915 (class 2606 OID 26439)
-- Name: ingrediente ingrediente_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".ingrediente
    ADD CONSTRAINT ingrediente_pkey PRIMARY KEY (ingrediente_id);


--
-- TOC entry 4917 (class 2606 OID 26441)
-- Name: inventario_producto inventario_producto_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".inventario_producto
    ADD CONSTRAINT inventario_producto_pkey PRIMARY KEY (inv_producto_id);


--
-- TOC entry 4919 (class 2606 OID 26443)
-- Name: lote_inventario lote_inventario_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".lote_inventario
    ADD CONSTRAINT lote_inventario_pkey PRIMARY KEY (lote_id);


--
-- TOC entry 4921 (class 2606 OID 26445)
-- Name: metodo_pago metodo_pago_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".metodo_pago
    ADD CONSTRAINT metodo_pago_pkey PRIMARY KEY (metodo_pago_id);


--
-- TOC entry 4923 (class 2606 OID 26447)
-- Name: pago_venta pago_venta_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pago_venta
    ADD CONSTRAINT pago_venta_pkey PRIMARY KEY (pago_venta_id);


--
-- TOC entry 4925 (class 2606 OID 26449)
-- Name: paso_receta paso_receta_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".paso_receta
    ADD CONSTRAINT paso_receta_pkey PRIMARY KEY (paso_id);


--
-- TOC entry 4927 (class 2606 OID 26451)
-- Name: pedido pedido_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (pedido_id);


--
-- TOC entry 4929 (class 2606 OID 26453)
-- Name: permiso permiso_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".permiso
    ADD CONSTRAINT permiso_pkey PRIMARY KEY (permiso_id);


--
-- TOC entry 4931 (class 2606 OID 26455)
-- Name: prioridad prioridad_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".prioridad
    ADD CONSTRAINT prioridad_pkey PRIMARY KEY (prioridad_id);


--
-- TOC entry 4933 (class 2606 OID 26457)
-- Name: producto producto_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (producto_id);


--
-- TOC entry 4935 (class 2606 OID 26459)
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (proveedor_id);


--
-- TOC entry 4939 (class 2606 OID 26461)
-- Name: receta_ingrediente receta_ingrediente_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".receta_ingrediente
    ADD CONSTRAINT receta_ingrediente_pkey PRIMARY KEY (receta_id, ingrediente_id);


--
-- TOC entry 4937 (class 2606 OID 26463)
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (receta_id);


--
-- TOC entry 4943 (class 2606 OID 26465)
-- Name: rol_permiso rol_permiso_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".rol_permiso
    ADD CONSTRAINT rol_permiso_pkey PRIMARY KEY (rol_id, permiso_id);


--
-- TOC entry 4941 (class 2606 OID 26467)
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (rol_id);


--
-- TOC entry 4945 (class 2606 OID 26469)
-- Name: unidad_medida unidad_medida_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".unidad_medida
    ADD CONSTRAINT unidad_medida_pkey PRIMARY KEY (unidad_medida_id);


--
-- TOC entry 4947 (class 2606 OID 26471)
-- Name: venta venta_pkey; Type: CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".venta
    ADD CONSTRAINT venta_pkey PRIMARY KEY (venta_id);


--
-- TOC entry 4948 (class 2606 OID 26472)
-- Name: agenda agenda_estado_agenda_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".agenda
    ADD CONSTRAINT agenda_estado_agenda_id_fkey FOREIGN KEY (estado_agenda_id) REFERENCES "vanabbyDB".estado_agenda(estado_agenda_id);


--
-- TOC entry 4949 (class 2606 OID 26477)
-- Name: agenda agenda_responsable_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".agenda
    ADD CONSTRAINT agenda_responsable_empleado_id_fkey FOREIGN KEY (responsable_empleado_id) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4950 (class 2606 OID 26482)
-- Name: agenda agenda_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".agenda
    ADD CONSTRAINT agenda_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES "vanabbyDB".venta(venta_id);


--
-- TOC entry 4951 (class 2606 OID 26487)
-- Name: anticipo anticipo_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".anticipo
    ADD CONSTRAINT anticipo_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES "vanabbyDB".cliente(cliente_id);


--
-- TOC entry 4952 (class 2606 OID 26492)
-- Name: anticipo anticipo_estado_anticipo_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".anticipo
    ADD CONSTRAINT anticipo_estado_anticipo_id_fkey FOREIGN KEY (estado_anticipo_id) REFERENCES "vanabbyDB".estado_anticipo(estado_anticipo_id);


--
-- TOC entry 4953 (class 2606 OID 26497)
-- Name: anticipo anticipo_metodo_pago_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".anticipo
    ADD CONSTRAINT anticipo_metodo_pago_id_fkey FOREIGN KEY (metodo_pago_id) REFERENCES "vanabbyDB".metodo_pago(metodo_pago_id);


--
-- TOC entry 4954 (class 2606 OID 26502)
-- Name: anticipo anticipo_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".anticipo
    ADD CONSTRAINT anticipo_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES "vanabbyDB".venta(venta_id);


--
-- TOC entry 4955 (class 2606 OID 26507)
-- Name: bloqueo bloqueo_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".bloqueo
    ADD CONSTRAINT bloqueo_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES "vanabbyDB".cliente(cliente_id);


--
-- TOC entry 4956 (class 2606 OID 26512)
-- Name: bloqueo bloqueo_desbloqueado_por_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".bloqueo
    ADD CONSTRAINT bloqueo_desbloqueado_por_empleado_id_fkey FOREIGN KEY (desbloqueado_por_empleado_id) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4957 (class 2606 OID 26517)
-- Name: bloqueo bloqueo_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".bloqueo
    ADD CONSTRAINT bloqueo_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4958 (class 2606 OID 26522)
-- Name: compra compra_estado_compra_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".compra
    ADD CONSTRAINT compra_estado_compra_id_fkey FOREIGN KEY (estado_compra_id) REFERENCES "vanabbyDB".estado_compra(estado_compra_id);


--
-- TOC entry 4959 (class 2606 OID 26527)
-- Name: compra compra_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".compra
    ADD CONSTRAINT compra_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES "vanabbyDB".proveedor(proveedor_id);


--
-- TOC entry 4960 (class 2606 OID 26532)
-- Name: detalle_compra detalle_compra_compra_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".detalle_compra
    ADD CONSTRAINT detalle_compra_compra_id_fkey FOREIGN KEY (compra_id) REFERENCES "vanabbyDB".compra(compra_id);


--
-- TOC entry 4961 (class 2606 OID 26537)
-- Name: detalle_compra detalle_compra_ingrediente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".detalle_compra
    ADD CONSTRAINT detalle_compra_ingrediente_id_fkey FOREIGN KEY (ingrediente_id) REFERENCES "vanabbyDB".ingrediente(ingrediente_id);


--
-- TOC entry 4962 (class 2606 OID 26542)
-- Name: detalle_venta detalle_venta_producto_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".detalle_venta
    ADD CONSTRAINT detalle_venta_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES "vanabbyDB".producto(producto_id);


--
-- TOC entry 4963 (class 2606 OID 26547)
-- Name: detalle_venta detalle_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".detalle_venta
    ADD CONSTRAINT detalle_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES "vanabbyDB".venta(venta_id);


--
-- TOC entry 4964 (class 2606 OID 26552)
-- Name: direccion_cliente direccion_cliente_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".direccion_cliente
    ADD CONSTRAINT direccion_cliente_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES "vanabbyDB".cliente(cliente_id);


--
-- TOC entry 4965 (class 2606 OID 26557)
-- Name: direccion_empleado direccion_empleado_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".direccion_empleado
    ADD CONSTRAINT direccion_empleado_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4966 (class 2606 OID 26562)
-- Name: direccion_proveedor direccion_proveedor_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".direccion_proveedor
    ADD CONSTRAINT direccion_proveedor_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES "vanabbyDB".proveedor(proveedor_id);


--
-- TOC entry 4967 (class 2606 OID 26567)
-- Name: empleado empleado_rol_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".empleado
    ADD CONSTRAINT empleado_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES "vanabbyDB".rol(rol_id);


--
-- TOC entry 4968 (class 2606 OID 26572)
-- Name: envio envio_direccion_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".envio
    ADD CONSTRAINT envio_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES "vanabbyDB".direccion_cliente(direccion_id);


--
-- TOC entry 4969 (class 2606 OID 26577)
-- Name: envio envio_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".envio
    ADD CONSTRAINT envio_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4970 (class 2606 OID 26582)
-- Name: envio envio_pedido_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".envio
    ADD CONSTRAINT envio_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES "vanabbyDB".pedido(pedido_id);


--
-- TOC entry 4971 (class 2606 OID 26587)
-- Name: ingrediente ingrediente_unidad_medida_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".ingrediente
    ADD CONSTRAINT ingrediente_unidad_medida_id_fkey FOREIGN KEY (unidad_medida_id) REFERENCES "vanabbyDB".unidad_medida(unidad_medida_id);


--
-- TOC entry 4972 (class 2606 OID 26592)
-- Name: inventario_producto inventario_producto_producto_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".inventario_producto
    ADD CONSTRAINT inventario_producto_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES "vanabbyDB".producto(producto_id);


--
-- TOC entry 4973 (class 2606 OID 26597)
-- Name: lote_inventario lote_inventario_ingrediente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".lote_inventario
    ADD CONSTRAINT lote_inventario_ingrediente_id_fkey FOREIGN KEY (ingrediente_id) REFERENCES "vanabbyDB".ingrediente(ingrediente_id);


--
-- TOC entry 4974 (class 2606 OID 26602)
-- Name: lote_inventario lote_inventario_unidad_medida_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".lote_inventario
    ADD CONSTRAINT lote_inventario_unidad_medida_id_fkey FOREIGN KEY (unidad_medida_id) REFERENCES "vanabbyDB".unidad_medida(unidad_medida_id);


--
-- TOC entry 4975 (class 2606 OID 26607)
-- Name: pago_venta pago_venta_metodo_pago_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pago_venta
    ADD CONSTRAINT pago_venta_metodo_pago_id_fkey FOREIGN KEY (metodo_pago_id) REFERENCES "vanabbyDB".metodo_pago(metodo_pago_id);


--
-- TOC entry 4976 (class 2606 OID 26612)
-- Name: pago_venta pago_venta_registrado_por_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pago_venta
    ADD CONSTRAINT pago_venta_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4977 (class 2606 OID 26617)
-- Name: pago_venta pago_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pago_venta
    ADD CONSTRAINT pago_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES "vanabbyDB".venta(venta_id);


--
-- TOC entry 4978 (class 2606 OID 26622)
-- Name: paso_receta paso_receta_receta_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".paso_receta
    ADD CONSTRAINT paso_receta_receta_id_fkey FOREIGN KEY (receta_id) REFERENCES "vanabbyDB".receta(receta_id);


--
-- TOC entry 4979 (class 2606 OID 26627)
-- Name: pedido pedido_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pedido
    ADD CONSTRAINT pedido_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES "vanabbyDB".cliente(cliente_id);


--
-- TOC entry 4980 (class 2606 OID 26632)
-- Name: pedido pedido_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pedido
    ADD CONSTRAINT pedido_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4981 (class 2606 OID 26637)
-- Name: pedido pedido_estado_pedido_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pedido
    ADD CONSTRAINT pedido_estado_pedido_id_fkey FOREIGN KEY (estado_pedido_id) REFERENCES "vanabbyDB".estado_pedido(estado_pedido_id);


--
-- TOC entry 4982 (class 2606 OID 26642)
-- Name: pedido pedido_prioridad_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".pedido
    ADD CONSTRAINT pedido_prioridad_id_fkey FOREIGN KEY (prioridad_id) REFERENCES "vanabbyDB".prioridad(prioridad_id);


--
-- TOC entry 4983 (class 2606 OID 26647)
-- Name: producto producto_categoria_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".producto
    ADD CONSTRAINT producto_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES "vanabbyDB".categoria(categoria_id);


--
-- TOC entry 4985 (class 2606 OID 26652)
-- Name: receta_ingrediente receta_ingrediente_ingrediente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".receta_ingrediente
    ADD CONSTRAINT receta_ingrediente_ingrediente_id_fkey FOREIGN KEY (ingrediente_id) REFERENCES "vanabbyDB".ingrediente(ingrediente_id);


--
-- TOC entry 4986 (class 2606 OID 26657)
-- Name: receta_ingrediente receta_ingrediente_receta_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".receta_ingrediente
    ADD CONSTRAINT receta_ingrediente_receta_id_fkey FOREIGN KEY (receta_id) REFERENCES "vanabbyDB".receta(receta_id);


--
-- TOC entry 4984 (class 2606 OID 26662)
-- Name: receta receta_producto_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".receta
    ADD CONSTRAINT receta_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES "vanabbyDB".producto(producto_id);


--
-- TOC entry 4987 (class 2606 OID 26667)
-- Name: rol_permiso rol_permiso_permiso_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".rol_permiso
    ADD CONSTRAINT rol_permiso_permiso_id_fkey FOREIGN KEY (permiso_id) REFERENCES "vanabbyDB".permiso(permiso_id);


--
-- TOC entry 4988 (class 2606 OID 26672)
-- Name: rol_permiso rol_permiso_rol_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".rol_permiso
    ADD CONSTRAINT rol_permiso_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES "vanabbyDB".rol(rol_id);


--
-- TOC entry 4989 (class 2606 OID 26677)
-- Name: venta venta_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".venta
    ADD CONSTRAINT venta_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES "vanabbyDB".cliente(cliente_id);


--
-- TOC entry 4990 (class 2606 OID 26682)
-- Name: venta venta_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".venta
    ADD CONSTRAINT venta_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES "vanabbyDB".empleado(empleado_id);


--
-- TOC entry 4991 (class 2606 OID 26687)
-- Name: venta venta_estado_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".venta
    ADD CONSTRAINT venta_estado_venta_id_fkey FOREIGN KEY (estado_venta_id) REFERENCES "vanabbyDB".estado_venta(estado_venta_id);


--
-- TOC entry 4992 (class 2606 OID 26692)
-- Name: venta venta_metodo_pago_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".venta
    ADD CONSTRAINT venta_metodo_pago_id_fkey FOREIGN KEY (metodo_pago_id) REFERENCES "vanabbyDB".metodo_pago(metodo_pago_id);


--
-- TOC entry 4993 (class 2606 OID 26697)
-- Name: venta venta_pedido_id_fkey; Type: FK CONSTRAINT; Schema: vanabbyDB; Owner: postgres
--

ALTER TABLE ONLY "vanabbyDB".venta
    ADD CONSTRAINT venta_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES "vanabbyDB".pedido(pedido_id);


-- Completed on 2026-11-12 21:47:25

--
-- PostgreSQL database dump complete
--

\unrestrict Iw0IyfPIzbj43qrn0SxO9TszFccPK5y71Yx01dWU0cFatpUlXeICcFV406smncS

