--
-- PostgreSQL database dump
--

\restrict WzZLLFrEZBNickKMdrfXkESXiOcOJg3YV6iHlbcO04qzDpbsZgEZ6IP6l1Qqqit

-- Dumped from database version 17.11
-- Dumped by pg_dump version 18.4

-- Started on 2026-11-25 07:52:47

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
-- TOC entry 6 (class 2615 OID 26707)
-- Name: vanabby; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA vanabby;


ALTER SCHEMA vanabby OWNER TO postgres;

--
-- TOC entry 365 (class 1255 OID 27614)
-- Name: fn_auditoria_financiera(); Type: FUNCTION; Schema: vanabby; Owner: postgres
--

CREATE FUNCTION vanabby.fn_auditoria_financiera() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_datos JSONB;
    v_id_original TEXT;
    v_empleado_id INTEGER;
    v_empleado VARCHAR(200);
    v_importe NUMERIC(14,2);
    v_movimiento VARCHAR(10);
    v_descripcion TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_datos := TO_JSONB(NEW);
        v_movimiento := 'INSERT';
    ELSIF TG_OP = 'UPDATE' THEN
        v_datos := TO_JSONB(NEW);
        v_movimiento := 'UPDATE';
    ELSE
        v_datos := TO_JSONB(OLD);
        v_movimiento := 'DELETE';
    END IF;
    -- Identificador del registro.
    CASE TG_TABLE_NAME
        WHEN 'compra' THEN
            v_id_original := v_datos ->> 'compra_id';
        WHEN 'detalle_compra' THEN
            v_id_original := v_datos ->> 'detalle_compra_id';
        WHEN 'venta' THEN
            v_id_original := v_datos ->> 'venta_id';
        WHEN 'detalle_venta' THEN
            v_id_original := v_datos ->> 'detalle_venta_id';
        WHEN 'pago_venta' THEN
            v_id_original := v_datos ->> 'pago_venta_id';
        WHEN 'anticipo' THEN
            v_id_original := v_datos ->> 'anticipo_id';
    END CASE;
    -- Obtener el importe según la tabla.
    CASE TG_TABLE_NAME
        WHEN 'compra' THEN
            v_importe := NULL;
        WHEN 'detalle_compra' THEN
            v_importe := NULLIF(v_datos ->> 'subtotal', '')::NUMERIC;
        WHEN 'venta' THEN
            v_importe := NULLIF(v_datos ->> 'total', '')::NUMERIC;
        WHEN 'detalle_venta' THEN
            v_importe := NULLIF(v_datos ->> 'subtotal', '')::NUMERIC;
        WHEN 'pago_venta' THEN
            v_importe := NULLIF(v_datos ->> 'monto', '')::NUMERIC;
        WHEN 'anticipo' THEN
            v_importe := NULLIF(v_datos ->> 'monto_anticipo', '')::NUMERIC;
    END CASE;
    -- Identificar al empleado.
    v_empleado_id := NULLIF(
        CURRENT_SETTING('app.id_empleado', TRUE),
        ''
    )::INTEGER;
    IF v_empleado_id IS NOT NULL THEN
        SELECT CONCAT_WS(
            ' ',
            nombre,
            ap_paterno,
            ap_materno
        )
        INTO v_empleado
        FROM vanabby.empleado
        WHERE empleado_id = v_empleado_id;
    END IF;
    v_descripcion := 'Movimiento financiero ' ||
        v_movimiento || ' realizado en la tabla ' ||
        TG_TABLE_NAME || '.';
    INSERT INTO vanabby.auditoria_financiera (
        empleado_id,
        empleado,
        tabla_afectada,
        id_registro,
        movimiento,
        importe,
        descripcion
    )
    VALUES (
        v_empleado_id,
        v_empleado,
        TG_TABLE_NAME,
        v_id_original,
        v_movimiento,
        v_importe,
        v_descripcion
    );
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION vanabby.fn_auditoria_financiera() OWNER TO postgres;

--
-- TOC entry 364 (class 1255 OID 27613)
-- Name: fn_auditoria_general(); Type: FUNCTION; Schema: vanabby; Owner: postgres
--

CREATE FUNCTION vanabby.fn_auditoria_general() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_datos_anteriores JSONB;
    v_datos_nuevos JSONB;
    v_id_original TEXT;
    v_empleado_id INTEGER;
    v_empleado VARCHAR(200);
    v_movimiento VARCHAR(10);
    v_descripcion TEXT;
    v_campos_modificados TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_datos_nuevos := TO_JSONB(NEW);
        v_movimiento := 'INSERT';
    ELSIF TG_OP = 'UPDATE' THEN
        v_datos_anteriores := TO_JSONB(OLD);
        v_datos_nuevos := TO_JSONB(NEW);
        v_movimiento := 'UPDATE';
    ELSIF TG_OP = 'DELETE' THEN
        v_datos_anteriores := TO_JSONB(OLD);
        v_movimiento := 'DELETE';
    END IF;
    -- Identificar el registro según la tabla afectada
    CASE TG_TABLE_NAME
        WHEN 'agenda' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'agenda_id';
        WHEN 'anticipo' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'anticipo_id';
        WHEN 'bloqueo' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'bloqueo_id';
        WHEN 'categoria' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'categoria_id';
        WHEN 'cliente' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'cliente_id';
        WHEN 'compra' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'compra_id';
        WHEN 'detalle_compra' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'detalle_compra_id';
        WHEN 'detalle_venta' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'detalle_venta_id';
        WHEN 'direccion_cliente', 'direccion_empleado', 'direccion_proveedor' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'direccion_id';
        WHEN 'empleado' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'empleado_id';
        WHEN 'envio' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'envio_id';
        WHEN 'estado_agenda' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'estado_agenda_id';
        WHEN 'estado_anticipo' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'estado_anticipo_id';
        WHEN 'estado_compra' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'estado_compra_id';
        WHEN 'estado_pedido' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'estado_pedido_id';
        WHEN 'estado_venta' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'estado_venta_id';
        WHEN 'ingrediente' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'ingrediente_id';
        WHEN 'inventario_producto' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'inv_producto_id';
        WHEN 'lote_inventario' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'lote_id';
        WHEN 'metodo_pago' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'metodo_pago_id';
        WHEN 'pago_venta' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'pago_venta_id';
        WHEN 'paso_receta' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'paso_id';
        WHEN 'pedido' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'pedido_id';
        WHEN 'permiso' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'permiso_id';
        WHEN 'prioridad' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'prioridad_id';
        WHEN 'producto' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'producto_id';
        WHEN 'proveedor' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'proveedor_id';
        WHEN 'receta' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'receta_id';
        WHEN 'receta_ingrediente' THEN
    		v_id_original := FORMAT(
        	'receta_id=%s, ingrediente_id=%s',
        		COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'receta_id',
        		COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'ingrediente_id'
    		);
        WHEN 'rol' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'rol_id';
        WHEN 'rol_permiso' THEN
    		v_id_original := FORMAT(
        	'rol_id=%s, permiso_id=%s',
        		COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'rol_id',
        		COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'permiso_id'
    		);
        WHEN 'unidad_medida' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'unidad_medida_id';
        WHEN 'venta' THEN
            v_id_original := COALESCE(v_datos_nuevos, v_datos_anteriores) ->> 'venta_id';
        ELSE
            v_id_original := NULL;
    END CASE;
    -- Identificar al empleado que realiza la operación.
    v_empleado_id := NULLIF(
        CURRENT_SETTING('app.id_empleado', TRUE),
        ''
    )::INTEGER;
    IF v_empleado_id IS NOT NULL THEN
        SELECT CONCAT_WS(
            ' ',
            nombre,
            ap_paterno,
            ap_materno
        )
        INTO v_empleado
        FROM vanabby.empleado
        WHERE empleado_id = v_empleado_id;
    END IF;
    -- Descripción del movimiento.
    IF TG_OP = 'INSERT' THEN
        v_descripcion := 'Se insertó un registro en la tabla ' ||
            TG_TABLE_NAME || '.';

    ELSIF TG_OP = 'DELETE' THEN
        v_descripcion := 'Se eliminó un registro de la tabla ' ||
            TG_TABLE_NAME || '.';
    ELSIF TG_OP = 'UPDATE' THEN
        SELECT STRING_AGG(e.key, ', ')
        INTO v_campos_modificados
        FROM JSONB_EACH(v_datos_nuevos) AS e
        WHERE v_datos_anteriores -> e.key IS DISTINCT FROM e.value;
        v_descripcion := 'Se actualizaron los campos: ' ||
            COALESCE(v_campos_modificados, 'sin cambios identificados') ||
            ' en la tabla ' || TG_TABLE_NAME || '.';
    END IF;
    INSERT INTO vanabby.auditoria_general (
        empleado_id,
        empleado,
        tabla_afectada,
        id_registro,
        movimiento,
        descripcion
    )
    VALUES (
        v_empleado_id,
        v_empleado,
        TG_TABLE_NAME,
        v_id_original,
        v_movimiento,
        v_descripcion
    );
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION vanabby.fn_auditoria_general() OWNER TO postgres;

--
-- TOC entry 352 (class 1255 OID 27612)
-- Name: fn_registrar_respaldo(); Type: FUNCTION; Schema: vanabby; Owner: postgres
--

CREATE FUNCTION vanabby.fn_registrar_respaldo() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_datos_anteriores JSONB;
    v_datos_nuevos JSONB;
    v_id_original INTEGER;
    v_empleado_id INTEGER;
    v_nombre_empleado VARCHAR(200);
    v_nombre_pk TEXT;
    v_operacion VARCHAR(10);
    v_descripcion TEXT;
BEGIN
    -- IDENTIFICAR LA OPERACION
    IF TG_OP = 'INSERT' THEN
        v_operacion := 'INSERT';
        v_datos_anteriores := NULL;
        v_datos_nuevos := TO_JSONB(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        v_operacion := 'UPDATE';
        v_datos_anteriores := TO_JSONB(OLD);
        v_datos_nuevos := TO_JSONB(NEW);
    ELSIF TG_OP = 'DELETE' THEN
        v_operacion := 'DELETE';
        v_datos_anteriores := TO_JSONB(OLD);
        v_datos_nuevos := NULL;
    END IF;
    -- IDENTIFICAR LA CLAVE PRIMARIA DE CADA TABLA
    v_nombre_pk := CASE TG_TABLE_NAME
        WHEN 'agenda' THEN 'agenda_id'
        WHEN 'anticipo' THEN 'anticipo_id'
        WHEN 'bloqueo' THEN 'bloqueo_id'
        WHEN 'categoria' THEN 'categoria_id'
        WHEN 'cliente' THEN 'cliente_id'
        WHEN 'compra' THEN 'compra_id'
        WHEN 'detalle_compra' THEN 'detalle_compra_id'
        WHEN 'detalle_venta' THEN 'detalle_venta_id'
        WHEN 'direccion_cliente' THEN 'direccion_id'
        WHEN 'direccion_empleado' THEN 'direccion_id'
        WHEN 'direccion_proveedor' THEN 'direccion_id'
        WHEN 'empleado' THEN 'empleado_id'
        WHEN 'envio' THEN 'envio_id'
        WHEN 'estado_agenda' THEN 'estado_agenda_id'
        WHEN 'estado_anticipo' THEN 'estado_anticipo_id'
        WHEN 'estado_compra' THEN 'estado_compra_id'
        WHEN 'estado_pedido' THEN 'estado_pedido_id'
        WHEN 'estado_venta' THEN 'estado_venta_id'
        WHEN 'ingrediente' THEN 'ingrediente_id'
        WHEN 'inventario_producto' THEN 'inv_producto_id'
        WHEN 'lote_inventario' THEN 'lote_id'
        WHEN 'metodo_pago' THEN 'metodo_pago_id'
        WHEN 'pago_venta' THEN 'pago_venta_id'
        WHEN 'paso_receta' THEN 'paso_id'
        WHEN 'pedido' THEN 'pedido_id'
        WHEN 'permiso' THEN 'permiso_id'
        WHEN 'prioridad' THEN 'prioridad_id'
        WHEN 'producto' THEN 'producto_id'
        WHEN 'proveedor' THEN 'proveedor_id'
        WHEN 'receta' THEN 'receta_id'
        WHEN 'receta_ingrediente' THEN 'receta_id'
        WHEN 'rol' THEN 'rol_id'
        WHEN 'rol_permiso' THEN 'rol_id'
        WHEN 'unidad_medida' THEN 'unidad_medida_id'
        WHEN 'venta' THEN 'venta_id'
        ELSE NULL
    END;
    -- OBTENER EL ID DEL REGISTRO ORIGINAL
    IF v_nombre_pk IS NULL THEN
        RAISE EXCEPTION
            'No se reconoce la clave primaria de la tabla %',
            TG_TABLE_NAME;
    END IF;
    v_id_original := COALESCE(
        (v_datos_nuevos ->> v_nombre_pk)::INTEGER,
        (v_datos_anteriores ->> v_nombre_pk)::INTEGER
    );
    -- IDENTIFICAR AL EMPLEADO QUE REALIZA LA OPERACION
    v_empleado_id := NULLIF(
        CURRENT_SETTING('app.id_empleado', TRUE),
        ''
    )::INTEGER;
    v_nombre_empleado := NULL;
    IF v_empleado_id IS NOT NULL THEN
        SELECT CONCAT_WS(
            ' ',
            e.nombre,
            e.ap_paterno,
            e.ap_materno
        )
        INTO v_nombre_empleado
        FROM vanabby.empleado e
        WHERE e.empleado_id = v_empleado_id;
    END IF;
    -- GENERAR DESCRIPCION DE LA OPERACION
    v_descripcion := FORMAT(
        'Operacion %s realizada sobre la tabla %s. Registro ID: %s.',
        v_operacion,
        TG_TABLE_NAME,
        v_id_original
    );
    -- INSERTAR INFORMACION EN LA TABLA DE RESPALDO
    EXECUTE FORMAT(
        'INSERT INTO vanabby.%I (
            fecha_respaldo,
            id_registro_original,
            empleado_id,
            nombre_empleado,
            operacion,
            descripcion,
            datos_anteriores,
            datos_nuevos
        )
        VALUES (
            CURRENT_TIMESTAMP,
            $1,
            $2,
            $3,
            $4,
            $5,
            $6,
            $7
        )',
        'backup_' || TG_TABLE_NAME
    )
    USING
        v_id_original,
        v_empleado_id,
        v_nombre_empleado,
        v_operacion,
        v_descripcion,
        v_datos_anteriores,
        v_datos_nuevos;
    -- FINALIZAR OPERACION
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$_$;


ALTER FUNCTION vanabby.fn_registrar_respaldo() OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 27615)
-- Name: fn_respaldar_auditorias(); Type: FUNCTION; Schema: vanabby; Owner: postgres
--

CREATE FUNCTION vanabby.fn_respaldar_auditorias() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_TABLE_NAME = 'auditoria_general' THEN
        INSERT INTO vanabby.backup_auditoria_general (
            auditoria_original_id,
            fecha_movimiento,
            empleado_id,
            empleado,
            tabla_afectada,
            id_registro,
            movimiento,
            descripcion
        )
        VALUES (
            NEW.auditoria_id,
            NEW.fecha_movimiento,
            NEW.empleado_id,
            NEW.empleado,
            NEW.tabla_afectada,
            NEW.id_registro,
            NEW.movimiento,
            NEW.descripcion
        );
    ELSIF TG_TABLE_NAME = 'auditoria_financiera' THEN
        INSERT INTO vanabby.backup_auditoria_financiera (
            auditoria_original_id,
            fecha_movimiento,
            empleado_id,
            empleado,
            tabla_afectada,
            id_registro,
            movimiento,
            importe,
            descripcion
        )
        VALUES (
            NEW.auditoria_financiera_id,
            NEW.fecha_movimiento,
            NEW.empleado_id,
            NEW.empleado,
            NEW.tabla_afectada,
            NEW.id_registro,
            NEW.movimiento,
            NEW.importe,
            NEW.descripcion
        );
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION vanabby.fn_respaldar_auditorias() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 26708)
-- Name: agenda; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.agenda (
    agenda_id integer NOT NULL,
    venta_id integer,
    fecha_programada timestamp without time zone,
    responsable_empleado_id integer,
    estado_agenda_id integer,
    notas text
);


ALTER TABLE vanabby.agenda OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 26713)
-- Name: anticipo; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.anticipo (
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


ALTER TABLE vanabby.anticipo OWNER TO postgres;

--
-- TOC entry 336 (class 1259 OID 27855)
-- Name: auditoria_financiera; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.auditoria_financiera (
    auditoria_financiera_id bigint NOT NULL,
    fecha_movimiento timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    empleado_id integer,
    empleado character varying(200),
    tabla_afectada character varying(100) NOT NULL,
    id_registro text,
    movimiento character varying(10) NOT NULL,
    importe numeric(14,2),
    descripcion text,
    CONSTRAINT auditoria_financiera_movimiento_check CHECK (((movimiento)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.auditoria_financiera OWNER TO postgres;

--
-- TOC entry 335 (class 1259 OID 27854)
-- Name: auditoria_financiera_auditoria_financiera_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.auditoria_financiera ALTER COLUMN auditoria_financiera_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.auditoria_financiera_auditoria_financiera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 334 (class 1259 OID 27845)
-- Name: auditoria_general; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.auditoria_general (
    auditoria_id bigint NOT NULL,
    fecha_movimiento timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    empleado_id integer,
    empleado character varying(200),
    tabla_afectada character varying(100) NOT NULL,
    id_registro text,
    movimiento character varying(10) NOT NULL,
    descripcion text,
    CONSTRAINT auditoria_general_movimiento_check CHECK (((movimiento)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.auditoria_general OWNER TO postgres;

--
-- TOC entry 333 (class 1259 OID 27844)
-- Name: auditoria_general_auditoria_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.auditoria_general ALTER COLUMN auditoria_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.auditoria_general_auditoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 288 (class 1259 OID 27301)
-- Name: backup_agenda; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_agenda (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_agenda_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_agenda OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 27300)
-- Name: backup_agenda_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_agenda ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_agenda_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 278 (class 1259 OID 27251)
-- Name: backup_anticipo; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_anticipo (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_anticipo_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_anticipo OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 27250)
-- Name: backup_anticipo_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_anticipo ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_anticipo_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 340 (class 1259 OID 27874)
-- Name: backup_auditoria_financiera; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_auditoria_financiera (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    auditoria_original_id bigint NOT NULL,
    fecha_movimiento timestamp with time zone NOT NULL,
    empleado_id integer,
    empleado character varying(200),
    tabla_afectada character varying(100) NOT NULL,
    id_registro text,
    movimiento character varying(10) NOT NULL,
    importe numeric(14,2),
    descripcion text
);


ALTER TABLE vanabby.backup_auditoria_financiera OWNER TO postgres;

--
-- TOC entry 339 (class 1259 OID 27873)
-- Name: backup_auditoria_financiera_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_auditoria_financiera ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_auditoria_financiera_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 338 (class 1259 OID 27865)
-- Name: backup_auditoria_general; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_auditoria_general (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    auditoria_original_id bigint NOT NULL,
    fecha_movimiento timestamp with time zone NOT NULL,
    empleado_id integer,
    empleado character varying(200),
    tabla_afectada character varying(100) NOT NULL,
    id_registro text,
    movimiento character varying(10) NOT NULL,
    descripcion text
);


ALTER TABLE vanabby.backup_auditoria_general OWNER TO postgres;

--
-- TOC entry 337 (class 1259 OID 27864)
-- Name: backup_auditoria_general_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_auditoria_general ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_auditoria_general_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 290 (class 1259 OID 27311)
-- Name: backup_bloqueo; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_bloqueo (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_bloqueo_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_bloqueo OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 27310)
-- Name: backup_bloqueo_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_bloqueo ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_bloqueo_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 292 (class 1259 OID 27321)
-- Name: backup_categoria; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_categoria (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_categoria_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_categoria OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 27320)
-- Name: backup_categoria_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_categoria ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_categoria_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 254 (class 1259 OID 27131)
-- Name: backup_cliente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_cliente (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_cliente_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_cliente OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 27130)
-- Name: backup_cliente_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_cliente ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_cliente_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 268 (class 1259 OID 27201)
-- Name: backup_compra; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_compra (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_compra_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_compra OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 27200)
-- Name: backup_compra_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_compra ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_compra_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 270 (class 1259 OID 27211)
-- Name: backup_detalle_compra; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_detalle_compra (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_detalle_compra_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_detalle_compra OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 27210)
-- Name: backup_detalle_compra_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_detalle_compra ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_detalle_compra_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 276 (class 1259 OID 27241)
-- Name: backup_detalle_venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_detalle_venta (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_detalle_venta_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_detalle_venta OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 27240)
-- Name: backup_detalle_venta_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_detalle_venta ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_detalle_venta_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 284 (class 1259 OID 27281)
-- Name: backup_direccion_cliente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_direccion_cliente (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_direccion_cliente_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_direccion_cliente OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 27280)
-- Name: backup_direccion_cliente_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_direccion_cliente ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_direccion_cliente_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 294 (class 1259 OID 27331)
-- Name: backup_direccion_empleado; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_direccion_empleado (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_direccion_empleado_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_direccion_empleado OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 27330)
-- Name: backup_direccion_empleado_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_direccion_empleado ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_direccion_empleado_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 286 (class 1259 OID 27291)
-- Name: backup_direccion_proveedor; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_direccion_proveedor (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_direccion_proveedor_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_direccion_proveedor OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 27290)
-- Name: backup_direccion_proveedor_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_direccion_proveedor ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_direccion_proveedor_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 256 (class 1259 OID 27141)
-- Name: backup_empleado; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_empleado (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_empleado_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_empleado OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 27140)
-- Name: backup_empleado_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_empleado ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_empleado_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 282 (class 1259 OID 27271)
-- Name: backup_envio; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_envio (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_envio_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_envio OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 27270)
-- Name: backup_envio_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_envio ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_envio_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 296 (class 1259 OID 27341)
-- Name: backup_estado_agenda; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_estado_agenda (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_estado_agenda_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_estado_agenda OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 27340)
-- Name: backup_estado_agenda_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_estado_agenda ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_estado_agenda_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 298 (class 1259 OID 27351)
-- Name: backup_estado_anticipo; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_estado_anticipo (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_estado_anticipo_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_estado_anticipo OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 27350)
-- Name: backup_estado_anticipo_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_estado_anticipo ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_estado_anticipo_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 300 (class 1259 OID 27361)
-- Name: backup_estado_compra; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_estado_compra (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_estado_compra_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_estado_compra OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 27360)
-- Name: backup_estado_compra_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_estado_compra ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_estado_compra_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 302 (class 1259 OID 27371)
-- Name: backup_estado_pedido; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_estado_pedido (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_estado_pedido_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_estado_pedido OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 27370)
-- Name: backup_estado_pedido_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_estado_pedido ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_estado_pedido_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 304 (class 1259 OID 27381)
-- Name: backup_estado_venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_estado_venta (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_estado_venta_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_estado_venta OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 27380)
-- Name: backup_estado_venta_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_estado_venta ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_estado_venta_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 260 (class 1259 OID 27161)
-- Name: backup_ingrediente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_ingrediente (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_ingrediente_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_ingrediente OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 27160)
-- Name: backup_ingrediente_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_ingrediente ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_ingrediente_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 264 (class 1259 OID 27181)
-- Name: backup_inventario_producto; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_inventario_producto (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_inventario_producto_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_inventario_producto OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 27180)
-- Name: backup_inventario_producto_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_inventario_producto ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_inventario_producto_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 266 (class 1259 OID 27191)
-- Name: backup_lote_inventario; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_lote_inventario (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_lote_inventario_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_lote_inventario OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 27190)
-- Name: backup_lote_inventario_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_lote_inventario ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_lote_inventario_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 306 (class 1259 OID 27391)
-- Name: backup_metodo_pago; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_metodo_pago (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_metodo_pago_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_metodo_pago OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 27390)
-- Name: backup_metodo_pago_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_metodo_pago ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_metodo_pago_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 280 (class 1259 OID 27261)
-- Name: backup_pago_venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_pago_venta (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_pago_venta_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_pago_venta OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 27260)
-- Name: backup_pago_venta_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_pago_venta ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_pago_venta_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 308 (class 1259 OID 27401)
-- Name: backup_paso_receta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_paso_receta (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_paso_receta_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_paso_receta OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 27400)
-- Name: backup_paso_receta_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_paso_receta ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_paso_receta_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 272 (class 1259 OID 27221)
-- Name: backup_pedido; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_pedido (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_pedido_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_pedido OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 27220)
-- Name: backup_pedido_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_pedido ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_pedido_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 310 (class 1259 OID 27411)
-- Name: backup_permiso; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_permiso (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_permiso_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_permiso OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 27410)
-- Name: backup_permiso_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_permiso ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_permiso_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 312 (class 1259 OID 27421)
-- Name: backup_prioridad; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_prioridad (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_prioridad_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_prioridad OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 27420)
-- Name: backup_prioridad_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_prioridad ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_prioridad_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 262 (class 1259 OID 27171)
-- Name: backup_producto; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_producto (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_producto_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_producto OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 27170)
-- Name: backup_producto_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_producto ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_producto_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 258 (class 1259 OID 27151)
-- Name: backup_proveedor; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_proveedor (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_proveedor_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_proveedor OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 27150)
-- Name: backup_proveedor_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_proveedor ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_proveedor_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 314 (class 1259 OID 27431)
-- Name: backup_receta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_receta (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_receta_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_receta OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 27430)
-- Name: backup_receta_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_receta ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_receta_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 316 (class 1259 OID 27441)
-- Name: backup_receta_ingrediente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_receta_ingrediente (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_receta_ingrediente_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_receta_ingrediente OWNER TO postgres;

--
-- TOC entry 315 (class 1259 OID 27440)
-- Name: backup_receta_ingrediente_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_receta_ingrediente ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_receta_ingrediente_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 318 (class 1259 OID 27451)
-- Name: backup_rol; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_rol (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_rol_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_rol OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 27450)
-- Name: backup_rol_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_rol ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_rol_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 320 (class 1259 OID 27461)
-- Name: backup_rol_permiso; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_rol_permiso (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_rol_permiso_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_rol_permiso OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 27460)
-- Name: backup_rol_permiso_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_rol_permiso ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_rol_permiso_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 322 (class 1259 OID 27471)
-- Name: backup_unidad_medida; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_unidad_medida (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_unidad_medida_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_unidad_medida OWNER TO postgres;

--
-- TOC entry 321 (class 1259 OID 27470)
-- Name: backup_unidad_medida_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_unidad_medida ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_unidad_medida_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 274 (class 1259 OID 27231)
-- Name: backup_venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.backup_venta (
    backup_id bigint NOT NULL,
    fecha_respaldo timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_registro_original integer NOT NULL,
    empleado_id integer,
    nombre_empleado character varying(200),
    operacion character varying(10) NOT NULL,
    descripcion text,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    CONSTRAINT backup_venta_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE vanabby.backup_venta OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 27230)
-- Name: backup_venta_backup_id_seq; Type: SEQUENCE; Schema: vanabby; Owner: postgres
--

ALTER TABLE vanabby.backup_venta ALTER COLUMN backup_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME vanabby.backup_venta_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 26716)
-- Name: bloqueo; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.bloqueo (
    bloqueo_id integer NOT NULL,
    empleado_id integer,
    cliente_id integer,
    fecha_bloqueo timestamp without time zone,
    intentos_acumulados integer NOT NULL,
    desbloqueado_por_empleado_id integer,
    fecha_desbloqueo timestamp without time zone,
    motivo text
);


ALTER TABLE vanabby.bloqueo OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 26721)
-- Name: categoria; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.categoria (
    categoria_id integer NOT NULL,
    nombre_categoria character varying(80) NOT NULL
);


ALTER TABLE vanabby.categoria OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 26724)
-- Name: cliente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.cliente (
    cliente_id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    ap_paterno character varying(255),
    ap_materno character varying(255),
    telefono character varying(255),
    correo character varying(255),
    creado_en timestamp without time zone
);


ALTER TABLE vanabby.cliente OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 26727)
-- Name: compra; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.compra (
    compra_id integer NOT NULL,
    proveedor_id integer,
    creado_en timestamp without time zone,
    fecha_esperada date,
    estado_compra_id integer
);


ALTER TABLE vanabby.compra OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 26730)
-- Name: detalle_compra; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.detalle_compra (
    detalle_compra_id integer NOT NULL,
    compra_id integer,
    ingrediente_id integer,
    cantidad numeric(12,4) NOT NULL,
    precio_unitario numeric(12,6) NOT NULL,
    subtotal numeric(12,2) NOT NULL
);


ALTER TABLE vanabby.detalle_compra OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 26733)
-- Name: detalle_venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.detalle_venta (
    detalle_venta_id integer NOT NULL,
    venta_id integer,
    producto_id integer,
    cantidad integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    subtotal numeric(12,2) NOT NULL
);


ALTER TABLE vanabby.detalle_venta OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 26736)
-- Name: direccion_cliente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.direccion_cliente (
    direccion_id integer NOT NULL,
    cliente_id integer NOT NULL,
    alias character varying(255),
    calle character varying(255),
    numero character varying(255),
    colonia character varying(255),
    ciudad character varying(255),
    estado_geo character varying(255),
    cp character varying(255),
    es_principal smallint
);


ALTER TABLE vanabby.direccion_cliente OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 26739)
-- Name: direccion_empleado; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.direccion_empleado (
    direccion_id integer NOT NULL,
    empleado_id integer NOT NULL,
    alias character varying(255),
    calle character varying(255),
    numero character varying(255),
    colonia character varying(255),
    ciudad character varying(255),
    estado_geo character varying(255),
    cp character varying(255),
    es_principal smallint
);


ALTER TABLE vanabby.direccion_empleado OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 26742)
-- Name: direccion_proveedor; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.direccion_proveedor (
    direccion_id integer NOT NULL,
    proveedor_id integer NOT NULL,
    alias character varying(255),
    calle character varying(255),
    numero character varying(255),
    colonia character varying(255),
    ciudad character varying(255),
    estado_geo character varying(255),
    cp character varying(255),
    es_principal smallint
);


ALTER TABLE vanabby.direccion_proveedor OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 26745)
-- Name: empleado; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.empleado (
    empleado_id integer NOT NULL,
    nombre_usuario character varying(255) NOT NULL,
    clave_hash character varying(255) NOT NULL,
    nombre character varying(255),
    ap_paterno character varying(255),
    ap_materno character varying(255),
    rol_id integer,
    bloqueado smallint,
    intentos_fallidos integer,
    ultimo_intento timestamp without time zone,
    creado_en timestamp without time zone
);


ALTER TABLE vanabby.empleado OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 26750)
-- Name: envio; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.envio (
    envio_id integer NOT NULL,
    pedido_id integer NOT NULL,
    direccion_id integer NOT NULL,
    empleado_id integer,
    costo_envio numeric(12,2),
    fecha_salida timestamp without time zone,
    fecha_entrega_real timestamp without time zone,
    notas text
);


ALTER TABLE vanabby.envio OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 26755)
-- Name: estado_agenda; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.estado_agenda (
    estado_agenda_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE vanabby.estado_agenda OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 26758)
-- Name: estado_anticipo; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.estado_anticipo (
    estado_anticipo_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE vanabby.estado_anticipo OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 26761)
-- Name: estado_compra; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.estado_compra (
    estado_compra_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE vanabby.estado_compra OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 26764)
-- Name: estado_pedido; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.estado_pedido (
    estado_pedido_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE vanabby.estado_pedido OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 26767)
-- Name: estado_venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.estado_venta (
    estado_venta_id integer NOT NULL,
    nombre_estado character varying(30) NOT NULL
);


ALTER TABLE vanabby.estado_venta OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 26770)
-- Name: ingrediente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.ingrediente (
    ingrediente_id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    unidad_medida_id integer NOT NULL,
    costo_por_unidad numeric(12,6)
);


ALTER TABLE vanabby.ingrediente OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 26773)
-- Name: inventario_producto; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.inventario_producto (
    inv_producto_id integer NOT NULL,
    producto_id integer NOT NULL,
    stock_disponible integer NOT NULL,
    stock_minimo integer NOT NULL,
    actualizado_en timestamp without time zone
);


ALTER TABLE vanabby.inventario_producto OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 26776)
-- Name: lote_inventario; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.lote_inventario (
    lote_id integer NOT NULL,
    ingrediente_id integer,
    numero_lote character varying(50),
    cantidad numeric(12,4),
    unidad_medida_id integer,
    fecha_caducidad date,
    creado_en timestamp without time zone
);


ALTER TABLE vanabby.lote_inventario OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 26779)
-- Name: metodo_pago; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.metodo_pago (
    metodo_pago_id integer NOT NULL,
    nombre_metodo character varying(255) NOT NULL
);


ALTER TABLE vanabby.metodo_pago OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 26782)
-- Name: pago_venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.pago_venta (
    pago_venta_id integer NOT NULL,
    venta_id integer,
    metodo_pago_id integer,
    monto numeric(12,2) NOT NULL,
    pagado_en timestamp without time zone,
    registrado_por integer
);


ALTER TABLE vanabby.pago_venta OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 26785)
-- Name: paso_receta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.paso_receta (
    paso_id integer NOT NULL,
    receta_id integer,
    numero_paso integer,
    descripcion character varying(255)
);


ALTER TABLE vanabby.paso_receta OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 26788)
-- Name: pedido; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.pedido (
    pedido_id integer NOT NULL,
    cliente_id integer NOT NULL,
    empleado_id integer NOT NULL,
    estado_pedido_id integer NOT NULL,
    prioridad_id integer NOT NULL,
    fecha_pedido timestamp without time zone NOT NULL,
    fecha_entrega_programada timestamp without time zone
);


ALTER TABLE vanabby.pedido OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 26791)
-- Name: permiso; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.permiso (
    permiso_id integer NOT NULL,
    nombre_permiso character varying(100) NOT NULL,
    descripcion text
);


ALTER TABLE vanabby.permiso OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 26796)
-- Name: prioridad; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.prioridad (
    prioridad_id integer NOT NULL,
    nombre_prioridad character varying(50) NOT NULL
);


ALTER TABLE vanabby.prioridad OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 26799)
-- Name: producto; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.producto (
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


ALTER TABLE vanabby.producto OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 26804)
-- Name: proveedor; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.proveedor (
    proveedor_id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    contacto_nombre character varying(255),
    contacto_ap_paterno character varying(255),
    contacto_ap_materno character varying(255),
    telefono character varying(255),
    correo character varying(255),
    notas text
);


ALTER TABLE vanabby.proveedor OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 26809)
-- Name: receta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.receta (
    receta_id integer NOT NULL,
    producto_id integer,
    rendimiento integer,
    tiempo_estimado_min integer
);


ALTER TABLE vanabby.receta OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 26812)
-- Name: receta_ingrediente; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.receta_ingrediente (
    receta_id integer NOT NULL,
    ingrediente_id integer NOT NULL,
    cantidad numeric(12,4)
);


ALTER TABLE vanabby.receta_ingrediente OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 26815)
-- Name: rol; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.rol (
    rol_id integer NOT NULL,
    nombre_rol character varying(50) NOT NULL,
    descripcion text
);


ALTER TABLE vanabby.rol OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 26820)
-- Name: rol_permiso; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.rol_permiso (
    rol_id integer NOT NULL,
    permiso_id integer NOT NULL
);


ALTER TABLE vanabby.rol_permiso OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 26823)
-- Name: unidad_medida; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.unidad_medida (
    unidad_medida_id integer NOT NULL,
    simbolo character varying(10) NOT NULL,
    descripcion character varying(60)
);


ALTER TABLE vanabby.unidad_medida OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 26826)
-- Name: venta; Type: TABLE; Schema: vanabby; Owner: postgres
--

CREATE TABLE vanabby.venta (
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


ALTER TABLE vanabby.venta OWNER TO postgres;

--
-- TOC entry 341 (class 1259 OID 27970)
-- Name: vista_agenda; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_agenda AS
 SELECT a.agenda_id,
    a.venta_id,
    a.fecha_programada,
    a.responsable_empleado_id,
    concat_ws(' '::text, e.nombre, e.ap_paterno, e.ap_materno) AS nombre_responsable,
    a.estado_agenda_id,
    ea.nombre_estado AS estado_agenda,
    a.notas
   FROM ((vanabby.agenda a
     LEFT JOIN vanabby.empleado e ON ((a.responsable_empleado_id = e.empleado_id)))
     LEFT JOIN vanabby.estado_agenda ea ON ((a.estado_agenda_id = ea.estado_agenda_id)));


ALTER VIEW vanabby.vista_agenda OWNER TO postgres;

--
-- TOC entry 342 (class 1259 OID 27975)
-- Name: vista_anticipos; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_anticipos AS
 SELECT a.anticipo_id,
    a.venta_id,
    a.cliente_id,
    concat_ws(' '::text, c.nombre, c.ap_paterno, c.ap_materno) AS nombre_cliente,
    a.monto_anticipo,
    a.monto_restante,
    a.fecha_registro,
    a.fecha_limite,
    a.estado_anticipo_id,
    ea.nombre_estado AS estado_anticipo,
    a.metodo_pago_id,
    mp.nombre_metodo
   FROM (((vanabby.anticipo a
     LEFT JOIN vanabby.cliente c ON ((a.cliente_id = c.cliente_id)))
     LEFT JOIN vanabby.estado_anticipo ea ON ((a.estado_anticipo_id = ea.estado_anticipo_id)))
     LEFT JOIN vanabby.metodo_pago mp ON ((a.metodo_pago_id = mp.metodo_pago_id)));


ALTER VIEW vanabby.vista_anticipos OWNER TO postgres;

--
-- TOC entry 343 (class 1259 OID 27980)
-- Name: vista_bloqueos; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_bloqueos AS
 SELECT b.bloqueo_id,
    b.empleado_id,
    concat_ws(' '::text, eb.nombre, eb.ap_paterno, eb.ap_materno) AS nombre_empleado_bloqueado,
    b.cliente_id,
    concat_ws(' '::text, c.nombre, c.ap_paterno, c.ap_materno) AS nombre_cliente,
    b.fecha_bloqueo,
    b.intentos_acumulados,
    b.desbloqueado_por_empleado_id,
    concat_ws(' '::text, ed.nombre, ed.ap_paterno, ed.ap_materno) AS nombre_empleado_desbloqueo,
    b.fecha_desbloqueo,
    b.motivo
   FROM (((vanabby.bloqueo b
     LEFT JOIN vanabby.empleado eb ON ((b.empleado_id = eb.empleado_id)))
     LEFT JOIN vanabby.cliente c ON ((b.cliente_id = c.cliente_id)))
     LEFT JOIN vanabby.empleado ed ON ((b.desbloqueado_por_empleado_id = ed.empleado_id)));


ALTER VIEW vanabby.vista_bloqueos OWNER TO postgres;

--
-- TOC entry 349 (class 1259 OID 28030)
-- Name: vista_clientes; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_clientes AS
 SELECT c.cliente_id,
    c.nombre,
    c.ap_paterno,
    c.ap_materno,
    c.telefono,
    c.correo,
    c.creado_en,
    d.direccion_id,
    d.alias AS alias_direccion,
    d.calle,
    d.numero,
    d.colonia,
    d.ciudad,
    d.estado_geo,
    d.cp,
    d.es_principal
   FROM (vanabby.cliente c
     LEFT JOIN vanabby.direccion_cliente d ON ((c.cliente_id = d.cliente_id)));


ALTER VIEW vanabby.vista_clientes OWNER TO postgres;

--
-- TOC entry 344 (class 1259 OID 27990)
-- Name: vista_compras; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_compras AS
 SELECT c.compra_id,
    c.proveedor_id,
    p.nombre AS nombre_proveedor,
    c.creado_en,
    c.fecha_esperada,
    c.estado_compra_id,
    ec.nombre_estado
   FROM ((vanabby.compra c
     LEFT JOIN vanabby.proveedor p ON ((c.proveedor_id = p.proveedor_id)))
     LEFT JOIN vanabby.estado_compra ec ON ((c.estado_compra_id = ec.estado_compra_id)));


ALTER VIEW vanabby.vista_compras OWNER TO postgres;

--
-- TOC entry 330 (class 1259 OID 27565)
-- Name: vista_detalle_compras; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_detalle_compras AS
 SELECT dc.detalle_compra_id,
    dc.compra_id,
    dc.ingrediente_id,
    i.nombre AS nombre_ingrediente,
    dc.cantidad,
    dc.precio_unitario,
    dc.subtotal
   FROM (vanabby.detalle_compra dc
     LEFT JOIN vanabby.ingrediente i ON ((dc.ingrediente_id = i.ingrediente_id)));


ALTER VIEW vanabby.vista_detalle_compras OWNER TO postgres;

--
-- TOC entry 331 (class 1259 OID 27579)
-- Name: vista_detalle_ventas; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_detalle_ventas AS
 SELECT dv.detalle_venta_id,
    dv.venta_id,
    dv.producto_id,
    p.sku,
    p.nombre AS nombre_producto,
    dv.cantidad,
    dv.precio_unitario,
    dv.subtotal
   FROM (vanabby.detalle_venta dv
     LEFT JOIN vanabby.producto p ON ((dv.producto_id = p.producto_id)));


ALTER VIEW vanabby.vista_detalle_ventas OWNER TO postgres;

--
-- TOC entry 345 (class 1259 OID 27994)
-- Name: vista_empleados; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_empleados AS
 SELECT e.empleado_id,
    e.nombre_usuario,
    e.nombre,
    e.ap_paterno,
    e.ap_materno,
    e.rol_id,
    r.nombre_rol,
    e.bloqueado,
    e.intentos_fallidos,
    e.ultimo_intento,
    e.creado_en
   FROM (vanabby.empleado e
     LEFT JOIN vanabby.rol r ON ((e.rol_id = r.rol_id)));


ALTER VIEW vanabby.vista_empleados OWNER TO postgres;

--
-- TOC entry 351 (class 1259 OID 28040)
-- Name: vista_envios; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_envios AS
 SELECT en.envio_id,
    en.pedido_id,
    en.direccion_id,
    concat_ws(', '::text, d.calle, d.numero, d.colonia, d.ciudad, d.estado_geo, d.cp) AS direccion_entrega,
    en.empleado_id,
    concat_ws(' '::text, e.nombre, e.ap_paterno, e.ap_materno) AS nombre_empleado,
    en.costo_envio,
    en.fecha_salida,
    en.fecha_entrega_real,
    en.notas
   FROM ((vanabby.envio en
     LEFT JOIN vanabby.direccion_cliente d ON ((en.direccion_id = d.direccion_id)))
     LEFT JOIN vanabby.empleado e ON ((en.empleado_id = e.empleado_id)));


ALTER VIEW vanabby.vista_envios OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 27538)
-- Name: vista_ingredientes; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_ingredientes AS
 SELECT i.ingrediente_id,
    i.nombre,
    i.unidad_medida_id,
    u.simbolo,
    u.descripcion AS descripcion_unidad,
    i.costo_por_unidad
   FROM (vanabby.ingrediente i
     JOIN vanabby.unidad_medida u ON ((i.unidad_medida_id = u.unidad_medida_id)));


ALTER VIEW vanabby.vista_ingredientes OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 27556)
-- Name: vista_ingredientes_receta; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_ingredientes_receta AS
 SELECT ri.receta_id,
    r.producto_id,
    p.nombre AS nombre_producto,
    ri.ingrediente_id,
    i.nombre AS nombre_ingrediente,
    ri.cantidad,
    i.unidad_medida_id,
    u.simbolo,
    u.descripcion AS descripcion_unidad
   FROM ((((vanabby.receta_ingrediente ri
     JOIN vanabby.receta r ON ((ri.receta_id = r.receta_id)))
     LEFT JOIN vanabby.producto p ON ((r.producto_id = p.producto_id)))
     JOIN vanabby.ingrediente i ON ((ri.ingrediente_id = i.ingrediente_id)))
     LEFT JOIN vanabby.unidad_medida u ON ((i.unidad_medida_id = u.unidad_medida_id)));


ALTER VIEW vanabby.vista_ingredientes_receta OWNER TO postgres;

--
-- TOC entry 326 (class 1259 OID 27542)
-- Name: vista_inventario; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_inventario AS
 SELECT ip.inv_producto_id,
    ip.producto_id,
    p.sku,
    p.nombre AS nombre_producto,
    ip.stock_disponible,
    ip.stock_minimo,
    ip.actualizado_en,
        CASE
            WHEN (ip.stock_disponible <= ip.stock_minimo) THEN 'STOCK BAJO'::text
            ELSE 'STOCK SUFICIENTE'::text
        END AS estado_inventario
   FROM (vanabby.inventario_producto ip
     JOIN vanabby.producto p ON ((ip.producto_id = p.producto_id)));


ALTER VIEW vanabby.vista_inventario OWNER TO postgres;

--
-- TOC entry 327 (class 1259 OID 27547)
-- Name: vista_lotes_inventario; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_lotes_inventario AS
 SELECT li.lote_id,
    li.ingrediente_id,
    i.nombre AS nombre_ingrediente,
    li.numero_lote,
    li.cantidad,
    li.unidad_medida_id,
    u.simbolo,
    li.fecha_caducidad,
    li.creado_en,
        CASE
            WHEN (li.fecha_caducidad < CURRENT_DATE) THEN 'CADUCADO'::text
            WHEN (li.fecha_caducidad = CURRENT_DATE) THEN 'CADUCA HOY'::text
            ELSE 'VIGENTE'::text
        END AS estado_caducidad
   FROM ((vanabby.lote_inventario li
     LEFT JOIN vanabby.ingrediente i ON ((li.ingrediente_id = i.ingrediente_id)))
     LEFT JOIN vanabby.unidad_medida u ON ((li.unidad_medida_id = u.unidad_medida_id)));


ALTER VIEW vanabby.vista_lotes_inventario OWNER TO postgres;

--
-- TOC entry 346 (class 1259 OID 28003)
-- Name: vista_pagos_ventas; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_pagos_ventas AS
 SELECT pv.pago_venta_id,
    pv.venta_id,
    pv.metodo_pago_id,
    mp.nombre_metodo,
    pv.monto,
    pv.pagado_en,
    pv.registrado_por,
    concat_ws(' '::text, e.nombre, e.ap_paterno, e.ap_materno) AS nombre_empleado_registro
   FROM ((vanabby.pago_venta pv
     LEFT JOIN vanabby.metodo_pago mp ON ((pv.metodo_pago_id = mp.metodo_pago_id)))
     LEFT JOIN vanabby.empleado e ON ((pv.registrado_por = e.empleado_id)));


ALTER VIEW vanabby.vista_pagos_ventas OWNER TO postgres;

--
-- TOC entry 332 (class 1259 OID 27608)
-- Name: vista_pasos_receta; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_pasos_receta AS
 SELECT pr.paso_id,
    pr.receta_id,
    r.producto_id,
    p.nombre AS nombre_producto,
    pr.numero_paso,
    pr.descripcion
   FROM ((vanabby.paso_receta pr
     LEFT JOIN vanabby.receta r ON ((pr.receta_id = r.receta_id)))
     LEFT JOIN vanabby.producto p ON ((r.producto_id = p.producto_id)));


ALTER VIEW vanabby.vista_pasos_receta OWNER TO postgres;

--
-- TOC entry 347 (class 1259 OID 28008)
-- Name: vista_pedidos; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_pedidos AS
 SELECT pe.pedido_id,
    pe.cliente_id,
    concat_ws(' '::text, c.nombre, c.ap_paterno, c.ap_materno) AS nombre_cliente,
    pe.empleado_id,
    concat_ws(' '::text, e.nombre, e.ap_paterno, e.ap_materno) AS nombre_empleado,
    pe.estado_pedido_id,
    ep.nombre_estado AS estado_pedido,
    pe.prioridad_id,
    pr.nombre_prioridad,
    pe.fecha_pedido,
    pe.fecha_entrega_programada
   FROM ((((vanabby.pedido pe
     JOIN vanabby.cliente c ON ((pe.cliente_id = c.cliente_id)))
     JOIN vanabby.empleado e ON ((pe.empleado_id = e.empleado_id)))
     JOIN vanabby.estado_pedido ep ON ((pe.estado_pedido_id = ep.estado_pedido_id)))
     JOIN vanabby.prioridad pr ON ((pe.prioridad_id = pr.prioridad_id)));


ALTER VIEW vanabby.vista_pedidos OWNER TO postgres;

--
-- TOC entry 324 (class 1259 OID 27534)
-- Name: vista_productos; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_productos AS
 SELECT p.producto_id,
    p.sku,
    p.nombre,
    p.descripcion,
    p.imagen,
    p.categoria_id,
    c.nombre_categoria,
    p.precio,
    p.tiempo_preparacion_min,
    p.creado_en
   FROM (vanabby.producto p
     LEFT JOIN vanabby.categoria c ON ((p.categoria_id = c.categoria_id)));


ALTER VIEW vanabby.vista_productos OWNER TO postgres;

--
-- TOC entry 350 (class 1259 OID 28035)
-- Name: vista_proveedores; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_proveedores AS
 SELECT p.proveedor_id,
    p.nombre,
    p.contacto_nombre,
    p.contacto_ap_paterno,
    p.contacto_ap_materno,
    p.telefono,
    p.correo,
    p.notas,
    d.direccion_id,
    d.alias AS alias_direccion,
    d.calle,
    d.numero,
    d.colonia,
    d.ciudad,
    d.estado_geo,
    d.cp,
    d.es_principal
   FROM (vanabby.proveedor p
     LEFT JOIN vanabby.direccion_proveedor d ON ((p.proveedor_id = d.proveedor_id)));


ALTER VIEW vanabby.vista_proveedores OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 27552)
-- Name: vista_recetas; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_recetas AS
 SELECT r.receta_id,
    r.producto_id,
    p.nombre AS nombre_producto,
    p.sku,
    r.rendimiento,
    r.tiempo_estimado_min
   FROM (vanabby.receta r
     LEFT JOIN vanabby.producto p ON ((r.producto_id = p.producto_id)));


ALTER VIEW vanabby.vista_recetas OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 27530)
-- Name: vista_roles_permisos; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_roles_permisos AS
 SELECT r.rol_id,
    r.nombre_rol,
    r.descripcion AS descripcion_rol,
    p.permiso_id,
    p.nombre_permiso,
    p.descripcion AS descripcion_permiso
   FROM ((vanabby.rol r
     LEFT JOIN vanabby.rol_permiso rp ON ((r.rol_id = rp.rol_id)))
     LEFT JOIN vanabby.permiso p ON ((rp.permiso_id = p.permiso_id)));


ALTER VIEW vanabby.vista_roles_permisos OWNER TO postgres;

--
-- TOC entry 348 (class 1259 OID 28018)
-- Name: vista_ventas; Type: VIEW; Schema: vanabby; Owner: postgres
--

CREATE VIEW vanabby.vista_ventas AS
 SELECT v.venta_id,
    v.empleado_id,
    concat_ws(' '::text, e.nombre, e.ap_paterno, e.ap_materno) AS nombre_empleado,
    v.cliente_id,
    concat_ws(' '::text, c.nombre, c.ap_paterno, c.ap_materno) AS nombre_cliente,
    v.metodo_pago_id,
    mp.nombre_metodo,
    v.estado_venta_id,
    ev.nombre_estado AS estado_venta,
    v.pedido_id,
    v.fecha_venta,
    v.fecha_entrega_programada,
    v.total
   FROM ((((vanabby.venta v
     LEFT JOIN vanabby.empleado e ON ((v.empleado_id = e.empleado_id)))
     LEFT JOIN vanabby.cliente c ON ((v.cliente_id = c.cliente_id)))
     LEFT JOIN vanabby.metodo_pago mp ON ((v.metodo_pago_id = mp.metodo_pago_id)))
     LEFT JOIN vanabby.estado_venta ev ON ((v.estado_venta_id = ev.estado_venta_id)));


ALTER VIEW vanabby.vista_ventas OWNER TO postgres;

--
-- TOC entry 5718 (class 0 OID 26708)
-- Dependencies: 218
-- Data for Name: agenda; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.agenda (agenda_id, venta_id, fecha_programada, responsable_empleado_id, estado_agenda_id, notas) FROM stdin;
\.


--
-- TOC entry 5719 (class 0 OID 26713)
-- Dependencies: 219
-- Data for Name: anticipo; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.anticipo (anticipo_id, venta_id, cliente_id, monto_anticipo, monto_restante, fecha_registro, fecha_limite, estado_anticipo_id, metodo_pago_id) FROM stdin;
\.


--
-- TOC entry 5826 (class 0 OID 27855)
-- Dependencies: 336
-- Data for Name: auditoria_financiera; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.auditoria_financiera (auditoria_financiera_id, fecha_movimiento, empleado_id, empleado, tabla_afectada, id_registro, movimiento, importe, descripcion) FROM stdin;
\.


--
-- TOC entry 5824 (class 0 OID 27845)
-- Dependencies: 334
-- Data for Name: auditoria_general; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.auditoria_general (auditoria_id, fecha_movimiento, empleado_id, empleado, tabla_afectada, id_registro, movimiento, descripcion) FROM stdin;
1	2026-11-18 11:28:44.160219-06	\N	\N	rol	1	INSERT	Se insertó un registro en la tabla rol.
2	2026-11-18 11:28:44.160219-06	\N	\N	rol	2	INSERT	Se insertó un registro en la tabla rol.
3	2026-11-18 11:28:44.160219-06	\N	\N	rol	3	INSERT	Se insertó un registro en la tabla rol.
4	2026-11-18 11:28:44.160219-06	\N	\N	rol	4	INSERT	Se insertó un registro en la tabla rol.
5	2026-11-18 11:28:44.160219-06	\N	\N	permiso	1	INSERT	Se insertó un registro en la tabla permiso.
6	2026-11-18 11:28:44.160219-06	\N	\N	permiso	2	INSERT	Se insertó un registro en la tabla permiso.
7	2026-11-18 11:28:44.160219-06	\N	\N	permiso	3	INSERT	Se insertó un registro en la tabla permiso.
8	2026-11-18 11:28:44.160219-06	\N	\N	permiso	4	INSERT	Se insertó un registro en la tabla permiso.
9	2026-11-18 11:28:44.160219-06	\N	\N	permiso	5	INSERT	Se insertó un registro en la tabla permiso.
10	2026-11-18 11:28:44.160219-06	\N	\N	permiso	6	INSERT	Se insertó un registro en la tabla permiso.
11	2026-11-18 11:28:44.160219-06	\N	\N	permiso	7	INSERT	Se insertó un registro en la tabla permiso.
12	2026-11-18 11:28:44.160219-06	\N	\N	permiso	8	INSERT	Se insertó un registro en la tabla permiso.
13	2026-11-18 11:28:44.160219-06	\N	\N	permiso	9	INSERT	Se insertó un registro en la tabla permiso.
14	2026-11-18 11:28:44.160219-06	\N	\N	permiso	10	INSERT	Se insertó un registro en la tabla permiso.
15	2026-11-18 11:28:44.160219-06	\N	\N	permiso	11	INSERT	Se insertó un registro en la tabla permiso.
16	2026-11-18 11:28:44.160219-06	\N	\N	permiso	12	INSERT	Se insertó un registro en la tabla permiso.
17	2026-11-18 11:28:44.160219-06	\N	\N	permiso	13	INSERT	Se insertó un registro en la tabla permiso.
18	2026-11-18 11:28:44.160219-06	\N	\N	permiso	14	INSERT	Se insertó un registro en la tabla permiso.
19	2026-11-18 11:28:44.160219-06	\N	\N	permiso	15	INSERT	Se insertó un registro en la tabla permiso.
20	2026-11-18 11:28:44.160219-06	\N	\N	permiso	16	INSERT	Se insertó un registro en la tabla permiso.
21	2026-11-18 11:28:44.160219-06	\N	\N	permiso	17	INSERT	Se insertó un registro en la tabla permiso.
22	2026-11-18 11:28:44.160219-06	\N	\N	permiso	18	INSERT	Se insertó un registro en la tabla permiso.
23	2026-11-18 11:28:44.160219-06	\N	\N	permiso	19	INSERT	Se insertó un registro en la tabla permiso.
24	2026-11-18 11:28:44.160219-06	\N	\N	permiso	20	INSERT	Se insertó un registro en la tabla permiso.
25	2026-11-18 11:28:44.160219-06	\N	\N	permiso	21	INSERT	Se insertó un registro en la tabla permiso.
26	2026-11-18 11:28:44.160219-06	\N	\N	permiso	22	INSERT	Se insertó un registro en la tabla permiso.
27	2026-11-18 11:28:44.160219-06	\N	\N	permiso	23	INSERT	Se insertó un registro en la tabla permiso.
28	2026-11-18 11:28:44.160219-06	\N	\N	permiso	24	INSERT	Se insertó un registro en la tabla permiso.
29	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=1	INSERT	Se insertó un registro en la tabla rol_permiso.
30	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=2	INSERT	Se insertó un registro en la tabla rol_permiso.
31	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=3	INSERT	Se insertó un registro en la tabla rol_permiso.
32	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
33	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=5	INSERT	Se insertó un registro en la tabla rol_permiso.
34	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=6	INSERT	Se insertó un registro en la tabla rol_permiso.
35	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=7	INSERT	Se insertó un registro en la tabla rol_permiso.
36	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=8	INSERT	Se insertó un registro en la tabla rol_permiso.
37	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=9	INSERT	Se insertó un registro en la tabla rol_permiso.
38	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=10	INSERT	Se insertó un registro en la tabla rol_permiso.
39	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=11	INSERT	Se insertó un registro en la tabla rol_permiso.
40	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
41	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=13	INSERT	Se insertó un registro en la tabla rol_permiso.
42	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=14	INSERT	Se insertó un registro en la tabla rol_permiso.
43	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=15	INSERT	Se insertó un registro en la tabla rol_permiso.
44	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=16	INSERT	Se insertó un registro en la tabla rol_permiso.
45	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=17	INSERT	Se insertó un registro en la tabla rol_permiso.
46	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=18	INSERT	Se insertó un registro en la tabla rol_permiso.
47	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
48	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=20	INSERT	Se insertó un registro en la tabla rol_permiso.
49	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=21	INSERT	Se insertó un registro en la tabla rol_permiso.
50	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=22	INSERT	Se insertó un registro en la tabla rol_permiso.
51	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=23	INSERT	Se insertó un registro en la tabla rol_permiso.
52	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=24	INSERT	Se insertó un registro en la tabla rol_permiso.
53	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
54	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=5	INSERT	Se insertó un registro en la tabla rol_permiso.
55	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=6	INSERT	Se insertó un registro en la tabla rol_permiso.
56	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=7	INSERT	Se insertó un registro en la tabla rol_permiso.
57	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=8	INSERT	Se insertó un registro en la tabla rol_permiso.
58	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=9	INSERT	Se insertó un registro en la tabla rol_permiso.
59	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=10	INSERT	Se insertó un registro en la tabla rol_permiso.
60	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
61	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
62	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=23	INSERT	Se insertó un registro en la tabla rol_permiso.
63	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=24	INSERT	Se insertó un registro en la tabla rol_permiso.
64	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=1	INSERT	Se insertó un registro en la tabla rol_permiso.
65	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=2	INSERT	Se insertó un registro en la tabla rol_permiso.
66	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
67	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=8	INSERT	Se insertó un registro en la tabla rol_permiso.
68	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=10	INSERT	Se insertó un registro en la tabla rol_permiso.
69	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
70	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=13	INSERT	Se insertó un registro en la tabla rol_permiso.
71	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=14	INSERT	Se insertó un registro en la tabla rol_permiso.
72	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=15	INSERT	Se insertó un registro en la tabla rol_permiso.
73	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=16	INSERT	Se insertó un registro en la tabla rol_permiso.
74	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=17	INSERT	Se insertó un registro en la tabla rol_permiso.
75	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
76	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=1	INSERT	Se insertó un registro en la tabla rol_permiso.
77	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
78	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
79	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=17	INSERT	Se insertó un registro en la tabla rol_permiso.
80	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=18	INSERT	Se insertó un registro en la tabla rol_permiso.
81	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
82	2026-11-18 11:28:44.160219-06	\N	\N	empleado	1	INSERT	Se insertó un registro en la tabla empleado.
83	2026-11-18 11:28:44.160219-06	\N	\N	empleado	2	INSERT	Se insertó un registro en la tabla empleado.
84	2026-11-18 11:28:44.160219-06	\N	\N	empleado	3	INSERT	Se insertó un registro en la tabla empleado.
85	2026-11-18 11:28:44.160219-06	\N	\N	empleado	4	INSERT	Se insertó un registro en la tabla empleado.
86	2026-11-23 07:36:21.526119-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
87	2026-11-23 07:54:36.362815-06	\N	\N	cliente	2	INSERT	Se insertó un registro en la tabla cliente.
88	2026-11-23 08:32:25.331627-06	\N	\N	cliente	2	UPDATE	Se actualizaron los campos: nombre, ap_materno, ap_paterno en la tabla cliente.
89	2026-11-23 10:13:05.841569-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
90	2026-11-23 10:13:47.105848-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
91	2026-11-23 10:14:25.228225-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
92	2026-11-23 10:16:01.770204-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
93	2026-11-23 12:18:33.594077-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
94	2026-11-23 12:31:40.761338-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
95	2026-11-23 20:31:31.097525-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
96	2026-11-23 20:31:43.794899-06	\N	\N	cliente	2	DELETE	Se eliminó un registro de la tabla cliente.
97	2026-11-23 20:33:20.724218-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
98	2026-11-23 20:36:09.110787-06	\N	\N	cliente	2	INSERT	Se insertó un registro en la tabla cliente.
99	2026-11-23 20:36:23.498136-06	\N	\N	cliente	3	INSERT	Se insertó un registro en la tabla cliente.
100	2026-11-24 11:23:52.150351-06	\N	\N	cliente	123	INSERT	Se insertó un registro en la tabla cliente.
\.


--
-- TOC entry 5788 (class 0 OID 27301)
-- Dependencies: 288
-- Data for Name: backup_agenda; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_agenda (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5778 (class 0 OID 27251)
-- Dependencies: 278
-- Data for Name: backup_anticipo; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_anticipo (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5830 (class 0 OID 27874)
-- Dependencies: 340
-- Data for Name: backup_auditoria_financiera; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_auditoria_financiera (backup_id, fecha_respaldo, auditoria_original_id, fecha_movimiento, empleado_id, empleado, tabla_afectada, id_registro, movimiento, importe, descripcion) FROM stdin;
\.


--
-- TOC entry 5828 (class 0 OID 27865)
-- Dependencies: 338
-- Data for Name: backup_auditoria_general; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_auditoria_general (backup_id, fecha_respaldo, auditoria_original_id, fecha_movimiento, empleado_id, empleado, tabla_afectada, id_registro, movimiento, descripcion) FROM stdin;
1	2026-11-18 11:28:44.160219-06	1	2026-11-18 11:28:44.160219-06	\N	\N	rol	1	INSERT	Se insertó un registro en la tabla rol.
2	2026-11-18 11:28:44.160219-06	2	2026-11-18 11:28:44.160219-06	\N	\N	rol	2	INSERT	Se insertó un registro en la tabla rol.
3	2026-11-18 11:28:44.160219-06	3	2026-11-18 11:28:44.160219-06	\N	\N	rol	3	INSERT	Se insertó un registro en la tabla rol.
4	2026-11-18 11:28:44.160219-06	4	2026-11-18 11:28:44.160219-06	\N	\N	rol	4	INSERT	Se insertó un registro en la tabla rol.
5	2026-11-18 11:28:44.160219-06	5	2026-11-18 11:28:44.160219-06	\N	\N	permiso	1	INSERT	Se insertó un registro en la tabla permiso.
6	2026-11-18 11:28:44.160219-06	6	2026-11-18 11:28:44.160219-06	\N	\N	permiso	2	INSERT	Se insertó un registro en la tabla permiso.
7	2026-11-18 11:28:44.160219-06	7	2026-11-18 11:28:44.160219-06	\N	\N	permiso	3	INSERT	Se insertó un registro en la tabla permiso.
8	2026-11-18 11:28:44.160219-06	8	2026-11-18 11:28:44.160219-06	\N	\N	permiso	4	INSERT	Se insertó un registro en la tabla permiso.
9	2026-11-18 11:28:44.160219-06	9	2026-11-18 11:28:44.160219-06	\N	\N	permiso	5	INSERT	Se insertó un registro en la tabla permiso.
10	2026-11-18 11:28:44.160219-06	10	2026-11-18 11:28:44.160219-06	\N	\N	permiso	6	INSERT	Se insertó un registro en la tabla permiso.
11	2026-11-18 11:28:44.160219-06	11	2026-11-18 11:28:44.160219-06	\N	\N	permiso	7	INSERT	Se insertó un registro en la tabla permiso.
12	2026-11-18 11:28:44.160219-06	12	2026-11-18 11:28:44.160219-06	\N	\N	permiso	8	INSERT	Se insertó un registro en la tabla permiso.
13	2026-11-18 11:28:44.160219-06	13	2026-11-18 11:28:44.160219-06	\N	\N	permiso	9	INSERT	Se insertó un registro en la tabla permiso.
14	2026-11-18 11:28:44.160219-06	14	2026-11-18 11:28:44.160219-06	\N	\N	permiso	10	INSERT	Se insertó un registro en la tabla permiso.
15	2026-11-18 11:28:44.160219-06	15	2026-11-18 11:28:44.160219-06	\N	\N	permiso	11	INSERT	Se insertó un registro en la tabla permiso.
16	2026-11-18 11:28:44.160219-06	16	2026-11-18 11:28:44.160219-06	\N	\N	permiso	12	INSERT	Se insertó un registro en la tabla permiso.
17	2026-11-18 11:28:44.160219-06	17	2026-11-18 11:28:44.160219-06	\N	\N	permiso	13	INSERT	Se insertó un registro en la tabla permiso.
18	2026-11-18 11:28:44.160219-06	18	2026-11-18 11:28:44.160219-06	\N	\N	permiso	14	INSERT	Se insertó un registro en la tabla permiso.
19	2026-11-18 11:28:44.160219-06	19	2026-11-18 11:28:44.160219-06	\N	\N	permiso	15	INSERT	Se insertó un registro en la tabla permiso.
20	2026-11-18 11:28:44.160219-06	20	2026-11-18 11:28:44.160219-06	\N	\N	permiso	16	INSERT	Se insertó un registro en la tabla permiso.
21	2026-11-18 11:28:44.160219-06	21	2026-11-18 11:28:44.160219-06	\N	\N	permiso	17	INSERT	Se insertó un registro en la tabla permiso.
22	2026-11-18 11:28:44.160219-06	22	2026-11-18 11:28:44.160219-06	\N	\N	permiso	18	INSERT	Se insertó un registro en la tabla permiso.
23	2026-11-18 11:28:44.160219-06	23	2026-11-18 11:28:44.160219-06	\N	\N	permiso	19	INSERT	Se insertó un registro en la tabla permiso.
24	2026-11-18 11:28:44.160219-06	24	2026-11-18 11:28:44.160219-06	\N	\N	permiso	20	INSERT	Se insertó un registro en la tabla permiso.
25	2026-11-18 11:28:44.160219-06	25	2026-11-18 11:28:44.160219-06	\N	\N	permiso	21	INSERT	Se insertó un registro en la tabla permiso.
26	2026-11-18 11:28:44.160219-06	26	2026-11-18 11:28:44.160219-06	\N	\N	permiso	22	INSERT	Se insertó un registro en la tabla permiso.
27	2026-11-18 11:28:44.160219-06	27	2026-11-18 11:28:44.160219-06	\N	\N	permiso	23	INSERT	Se insertó un registro en la tabla permiso.
28	2026-11-18 11:28:44.160219-06	28	2026-11-18 11:28:44.160219-06	\N	\N	permiso	24	INSERT	Se insertó un registro en la tabla permiso.
29	2026-11-18 11:28:44.160219-06	29	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=1	INSERT	Se insertó un registro en la tabla rol_permiso.
30	2026-11-18 11:28:44.160219-06	30	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=2	INSERT	Se insertó un registro en la tabla rol_permiso.
31	2026-11-18 11:28:44.160219-06	31	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=3	INSERT	Se insertó un registro en la tabla rol_permiso.
32	2026-11-18 11:28:44.160219-06	32	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
33	2026-11-18 11:28:44.160219-06	33	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=5	INSERT	Se insertó un registro en la tabla rol_permiso.
34	2026-11-18 11:28:44.160219-06	34	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=6	INSERT	Se insertó un registro en la tabla rol_permiso.
35	2026-11-18 11:28:44.160219-06	35	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=7	INSERT	Se insertó un registro en la tabla rol_permiso.
36	2026-11-18 11:28:44.160219-06	36	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=8	INSERT	Se insertó un registro en la tabla rol_permiso.
37	2026-11-18 11:28:44.160219-06	37	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=9	INSERT	Se insertó un registro en la tabla rol_permiso.
38	2026-11-18 11:28:44.160219-06	38	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=10	INSERT	Se insertó un registro en la tabla rol_permiso.
39	2026-11-18 11:28:44.160219-06	39	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=11	INSERT	Se insertó un registro en la tabla rol_permiso.
40	2026-11-18 11:28:44.160219-06	40	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
41	2026-11-18 11:28:44.160219-06	41	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=13	INSERT	Se insertó un registro en la tabla rol_permiso.
42	2026-11-18 11:28:44.160219-06	42	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=14	INSERT	Se insertó un registro en la tabla rol_permiso.
43	2026-11-18 11:28:44.160219-06	43	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=15	INSERT	Se insertó un registro en la tabla rol_permiso.
44	2026-11-18 11:28:44.160219-06	44	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=16	INSERT	Se insertó un registro en la tabla rol_permiso.
45	2026-11-18 11:28:44.160219-06	45	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=17	INSERT	Se insertó un registro en la tabla rol_permiso.
46	2026-11-18 11:28:44.160219-06	46	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=18	INSERT	Se insertó un registro en la tabla rol_permiso.
47	2026-11-18 11:28:44.160219-06	47	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
48	2026-11-18 11:28:44.160219-06	48	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=20	INSERT	Se insertó un registro en la tabla rol_permiso.
49	2026-11-18 11:28:44.160219-06	49	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=21	INSERT	Se insertó un registro en la tabla rol_permiso.
50	2026-11-18 11:28:44.160219-06	50	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=22	INSERT	Se insertó un registro en la tabla rol_permiso.
51	2026-11-18 11:28:44.160219-06	51	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=23	INSERT	Se insertó un registro en la tabla rol_permiso.
52	2026-11-18 11:28:44.160219-06	52	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=1, permiso_id=24	INSERT	Se insertó un registro en la tabla rol_permiso.
53	2026-11-18 11:28:44.160219-06	53	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
54	2026-11-18 11:28:44.160219-06	54	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=5	INSERT	Se insertó un registro en la tabla rol_permiso.
55	2026-11-18 11:28:44.160219-06	55	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=6	INSERT	Se insertó un registro en la tabla rol_permiso.
56	2026-11-18 11:28:44.160219-06	56	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=7	INSERT	Se insertó un registro en la tabla rol_permiso.
57	2026-11-18 11:28:44.160219-06	57	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=8	INSERT	Se insertó un registro en la tabla rol_permiso.
58	2026-11-18 11:28:44.160219-06	58	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=9	INSERT	Se insertó un registro en la tabla rol_permiso.
59	2026-11-18 11:28:44.160219-06	59	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=10	INSERT	Se insertó un registro en la tabla rol_permiso.
60	2026-11-18 11:28:44.160219-06	60	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
61	2026-11-18 11:28:44.160219-06	61	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
62	2026-11-18 11:28:44.160219-06	62	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=23	INSERT	Se insertó un registro en la tabla rol_permiso.
63	2026-11-18 11:28:44.160219-06	63	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=2, permiso_id=24	INSERT	Se insertó un registro en la tabla rol_permiso.
64	2026-11-18 11:28:44.160219-06	64	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=1	INSERT	Se insertó un registro en la tabla rol_permiso.
65	2026-11-18 11:28:44.160219-06	65	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=2	INSERT	Se insertó un registro en la tabla rol_permiso.
66	2026-11-18 11:28:44.160219-06	66	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
67	2026-11-18 11:28:44.160219-06	67	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=8	INSERT	Se insertó un registro en la tabla rol_permiso.
68	2026-11-18 11:28:44.160219-06	68	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=10	INSERT	Se insertó un registro en la tabla rol_permiso.
69	2026-11-18 11:28:44.160219-06	69	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
70	2026-11-18 11:28:44.160219-06	70	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=13	INSERT	Se insertó un registro en la tabla rol_permiso.
71	2026-11-18 11:28:44.160219-06	71	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=14	INSERT	Se insertó un registro en la tabla rol_permiso.
72	2026-11-18 11:28:44.160219-06	72	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=15	INSERT	Se insertó un registro en la tabla rol_permiso.
73	2026-11-18 11:28:44.160219-06	73	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=16	INSERT	Se insertó un registro en la tabla rol_permiso.
74	2026-11-18 11:28:44.160219-06	74	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=17	INSERT	Se insertó un registro en la tabla rol_permiso.
75	2026-11-18 11:28:44.160219-06	75	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=3, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
76	2026-11-18 11:28:44.160219-06	76	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=1	INSERT	Se insertó un registro en la tabla rol_permiso.
77	2026-11-18 11:28:44.160219-06	77	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=4	INSERT	Se insertó un registro en la tabla rol_permiso.
78	2026-11-18 11:28:44.160219-06	78	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=12	INSERT	Se insertó un registro en la tabla rol_permiso.
79	2026-11-18 11:28:44.160219-06	79	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=17	INSERT	Se insertó un registro en la tabla rol_permiso.
80	2026-11-18 11:28:44.160219-06	80	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=18	INSERT	Se insertó un registro en la tabla rol_permiso.
81	2026-11-18 11:28:44.160219-06	81	2026-11-18 11:28:44.160219-06	\N	\N	rol_permiso	rol_id=4, permiso_id=19	INSERT	Se insertó un registro en la tabla rol_permiso.
82	2026-11-18 11:28:44.160219-06	82	2026-11-18 11:28:44.160219-06	\N	\N	empleado	1	INSERT	Se insertó un registro en la tabla empleado.
83	2026-11-18 11:28:44.160219-06	83	2026-11-18 11:28:44.160219-06	\N	\N	empleado	2	INSERT	Se insertó un registro en la tabla empleado.
84	2026-11-18 11:28:44.160219-06	84	2026-11-18 11:28:44.160219-06	\N	\N	empleado	3	INSERT	Se insertó un registro en la tabla empleado.
85	2026-11-18 11:28:44.160219-06	85	2026-11-18 11:28:44.160219-06	\N	\N	empleado	4	INSERT	Se insertó un registro en la tabla empleado.
86	2026-11-23 07:36:21.526119-06	86	2026-11-23 07:36:21.526119-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
87	2026-11-23 07:54:36.362815-06	87	2026-11-23 07:54:36.362815-06	\N	\N	cliente	2	INSERT	Se insertó un registro en la tabla cliente.
88	2026-11-23 08:32:25.331627-06	88	2026-11-23 08:32:25.331627-06	\N	\N	cliente	2	UPDATE	Se actualizaron los campos: nombre, ap_materno, ap_paterno en la tabla cliente.
89	2026-11-23 10:13:05.841569-06	89	2026-11-23 10:13:05.841569-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
90	2026-11-23 10:13:47.105848-06	90	2026-11-23 10:13:47.105848-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
91	2026-11-23 10:14:25.228225-06	91	2026-11-23 10:14:25.228225-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
92	2026-11-23 10:16:01.770204-06	92	2026-11-23 10:16:01.770204-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
93	2026-11-23 12:18:33.594077-06	93	2026-11-23 12:18:33.594077-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
94	2026-11-23 12:31:40.761338-06	94	2026-11-23 12:31:40.761338-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
95	2026-11-23 20:31:31.097525-06	95	2026-11-23 20:31:31.097525-06	\N	\N	cliente	1	DELETE	Se eliminó un registro de la tabla cliente.
96	2026-11-23 20:31:43.794899-06	96	2026-11-23 20:31:43.794899-06	\N	\N	cliente	2	DELETE	Se eliminó un registro de la tabla cliente.
97	2026-11-23 20:33:20.724218-06	97	2026-11-23 20:33:20.724218-06	\N	\N	cliente	1	INSERT	Se insertó un registro en la tabla cliente.
98	2026-11-23 20:36:09.110787-06	98	2026-11-23 20:36:09.110787-06	\N	\N	cliente	2	INSERT	Se insertó un registro en la tabla cliente.
99	2026-11-23 20:36:23.498136-06	99	2026-11-23 20:36:23.498136-06	\N	\N	cliente	3	INSERT	Se insertó un registro en la tabla cliente.
100	2026-11-24 11:23:52.150351-06	100	2026-11-24 11:23:52.150351-06	\N	\N	cliente	123	INSERT	Se insertó un registro en la tabla cliente.
\.


--
-- TOC entry 5790 (class 0 OID 27311)
-- Dependencies: 290
-- Data for Name: backup_bloqueo; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_bloqueo (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5792 (class 0 OID 27321)
-- Dependencies: 292
-- Data for Name: backup_categoria; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_categoria (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5754 (class 0 OID 27131)
-- Dependencies: 254
-- Data for Name: backup_cliente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_cliente (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
1	2026-11-23 07:36:21.526119-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 1.	\N	{"correo": "vicente0102@hotmail.com", "nombre": "Vicente", "telefono": "9518742580", "creado_en": null, "ap_materno": "Guzmán", "ap_paterno": "Martínez", "cliente_id": 1}
2	2026-11-23 07:54:36.362815-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 2.	\N	{"correo": "ana@correo.com", "nombre": "Ana", "telefono": "9511234567", "creado_en": "2026-11-23T07:54:36.362815", "ap_materno": "GarcÃ­a", "ap_paterno": "LÃ³pez", "cliente_id": 2}
3	2026-11-23 08:32:25.331627-06	2	\N	\N	UPDATE	Operacion UPDATE realizada sobre la tabla cliente. Registro ID: 2.	{"correo": "ana@correo.com", "nombre": "Ana", "telefono": "9511234567", "creado_en": "2026-11-23T07:54:36.362815", "ap_materno": "GarcÃ­a", "ap_paterno": "LÃ³pez", "cliente_id": 2}	{"correo": "ana@correo.com", "nombre": "Jazmin", "telefono": "9511234567", "creado_en": "2026-11-23T07:54:36.362815", "ap_materno": "Flores", "ap_paterno": "Cortes", "cliente_id": 2}
4	2026-11-23 10:13:05.841569-06	1	\N	\N	DELETE	Operacion DELETE realizada sobre la tabla cliente. Registro ID: 1.	{"correo": "vicente0102@hotmail.com", "nombre": "Vicente", "telefono": "9518742580", "creado_en": null, "ap_materno": "Guzmán", "ap_paterno": "Martínez", "cliente_id": 1}	\N
5	2026-11-23 10:13:47.105848-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 1.	\N	{"correo": "vicente0102@hotmail.com", "nombre": "Vicente", "telefono": "9518742580", "creado_en": "2026-11-23T10:13:47.105848", "ap_materno": "GuzmÃ¡n", "ap_paterno": "MartÃ­nez", "cliente_id": 1}
6	2026-11-23 10:14:25.228225-06	1	\N	\N	DELETE	Operacion DELETE realizada sobre la tabla cliente. Registro ID: 1.	{"correo": "vicente0102@hotmail.com", "nombre": "Vicente", "telefono": "9518742580", "creado_en": "2026-11-23T10:13:47.105848", "ap_materno": "GuzmÃ¡n", "ap_paterno": "MartÃ­nez", "cliente_id": 1}	\N
7	2026-11-23 10:16:01.770204-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 1.	\N	{"correo": "vicente0102@hotmail.com", "nombre": "Vicente", "telefono": "9518742580", "creado_en": "2026-11-23T10:16:01.770204", "ap_materno": "GuzmÃ¡n", "ap_paterno": "MartÃ­nez", "cliente_id": 1}
8	2026-11-23 12:18:33.594077-06	1	\N	\N	DELETE	Operacion DELETE realizada sobre la tabla cliente. Registro ID: 1.	{"correo": "vicente0102@hotmail.com", "nombre": "Vicente", "telefono": "9518742580", "creado_en": "2026-11-23T10:16:01.770204", "ap_materno": "GuzmÃ¡n", "ap_paterno": "MartÃ­nez", "cliente_id": 1}	\N
9	2026-11-23 12:31:40.761338-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 1.	\N	{"correo": "ana@correo.com", "nombre": "Jazmin", "telefono": "9511234567", "creado_en": "2026-11-23T12:31:40.761338", "ap_materno": "Flores", "ap_paterno": "Cortes", "cliente_id": 1}
10	2026-11-23 20:31:31.097525-06	1	\N	\N	DELETE	Operacion DELETE realizada sobre la tabla cliente. Registro ID: 1.	{"correo": "ana@correo.com", "nombre": "Jazmin", "telefono": "9511234567", "creado_en": "2026-11-23T12:31:40.761338", "ap_materno": "Flores", "ap_paterno": "Cortes", "cliente_id": 1}	\N
11	2026-11-23 20:31:43.794899-06	2	\N	\N	DELETE	Operacion DELETE realizada sobre la tabla cliente. Registro ID: 2.	{"correo": "ana@correo.com", "nombre": "Jazmin", "telefono": "9511234567", "creado_en": "2026-11-23T07:54:36.362815", "ap_materno": "Flores", "ap_paterno": "Cortes", "cliente_id": 2}	\N
12	2026-11-23 20:33:20.724218-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 1.	\N	{"correo": "DEXsIXY6AxfJLy1/Uye0GM8IBU7bbos4a8maCt8GtZf9k89FIZV7XsJIvAC9vn51RZsCwCZe", "nombre": "oVQJPL0x3L9oBmPlMfPocf6uw/3n0NQpc4BxcF1GwcuQMg==", "telefono": "TGboG5wu869VR/rTx4juzYyLXhNLCGowFDzGAKtjKxPXjVRvIvw=", "creado_en": "2026-11-23T20:33:20.724218", "ap_materno": "dQjwviz0csq+2aWyhlFJhlLGZtj89/KTf+58VtmfHspONRhW", "ap_paterno": "AxYB8ytQcgTn4M3s/hsaxV5zrI/iqPm4nLRF0yL2FrUBLNUcSnOuSw==", "cliente_id": 1}
13	2026-11-23 20:36:09.110787-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 2.	\N	{"correo": "jhuZYQ+vYbujOMqCFIbSUTcykdXzorcmZEeWjNob0elD0M/lwoq8x9WR9o7YPBaHgKUNThXA", "nombre": "HF2CVhO52Nsb4EvAGukX6DTkcgTZ6ewq3lFd3zZeQvFpcA==", "telefono": "u+0DJRSzw434Jbhm+IOLxDWwQj+RvFM8rTJQ/pnDUjATE8TOmzg=", "creado_en": "2026-11-23T20:36:09.110787", "ap_materno": "kuKCIgse0T0TGZG+5u/ufrb/lNvpmJRGJet8TQ9zb5hNSNzc", "ap_paterno": "7s9qFwsNTfC8+mkliuDD1hJGnGzGfVfOwXFtWTTWwteppIZl0b0REQ==", "cliente_id": 2}
14	2026-11-23 20:36:23.498136-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 3.	\N	{"correo": "3EaByx48QKsSWBhHlvyyzrnHBL/ydEjbg7jGraVY1e9JWKntp+lsQzLJYDixUouu9eo4Ma9o", "nombre": "kXyEh00s3hFuofs/5/lDahQiB/0ODYp9GBelcnspPHvmrw==", "telefono": "0UqrwyT9a3xJLU6iXh14+pgbwuNkX/AyW9TzgUIlYNfs0UAbsOI=", "creado_en": "2026-11-23T20:36:23.498136", "ap_materno": "fC3mllIdGfJ87tfV+3OeIOH81S5zKi17sieB9LRUHxbuAVHM", "ap_paterno": "91N2/XtlxVCP8iwfYgI3sNJY1ShFDCJn5iO7GK9S0FTxTIVff5g4og==", "cliente_id": 3}
15	2026-11-24 11:23:52.150351-06	123	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla cliente. Registro ID: 123.	\N	{"correo": "gubsekaFrAoLVhYJ9O0kDiP6c6+bczRPhvnoTcNivRUZiyutmQbFIfSeGTw0l5kHJuOLIHI=", "nombre": "2bWtd6oYnu34xWpGuo8FFRXkPa8QNY6dgEqFWMr9qYnk", "telefono": "J8VF2o+XN/YRSoAicKKZkuyVbhw+daX6rFIC8zMzhmaKbP7JTvo=", "creado_en": "2026-11-24T11:23:52.150351", "ap_materno": "TrF0rPIkSFVL9bp3cPX2C6IbSssjb39bitjgU2XrDBU=", "ap_paterno": "gYGk+79hnzrXVxEVryujQB5ONfQP0MgneWzUFJ/jdcA=", "cliente_id": 123}
\.


--
-- TOC entry 5768 (class 0 OID 27201)
-- Dependencies: 268
-- Data for Name: backup_compra; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_compra (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5770 (class 0 OID 27211)
-- Dependencies: 270
-- Data for Name: backup_detalle_compra; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_detalle_compra (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5776 (class 0 OID 27241)
-- Dependencies: 276
-- Data for Name: backup_detalle_venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_detalle_venta (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5784 (class 0 OID 27281)
-- Dependencies: 284
-- Data for Name: backup_direccion_cliente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_direccion_cliente (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5794 (class 0 OID 27331)
-- Dependencies: 294
-- Data for Name: backup_direccion_empleado; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_direccion_empleado (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5786 (class 0 OID 27291)
-- Dependencies: 286
-- Data for Name: backup_direccion_proveedor; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_direccion_proveedor (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5756 (class 0 OID 27141)
-- Dependencies: 256
-- Data for Name: backup_empleado; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_empleado (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
1	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla empleado. Registro ID: 1.	\N	{"nombre": "PZU", "rol_id": 1, "bloqueado": 1, "creado_en": "2026-11-18T11:28:44.160219", "ap_materno": "Ramirez", "ap_paterno": "Mata", "clave_hash": "PENDIENTE_DE_CONFIGURAR", "empleado_id": 1, "nombre_usuario": "admin_pzu", "ultimo_intento": null, "intentos_fallidos": 0}
2	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla empleado. Registro ID: 2.	\N	{"nombre": "Daniel", "rol_id": 2, "bloqueado": 1, "creado_en": "2026-11-18T11:28:44.160219", "ap_materno": "De la Cruz", "ap_paterno": "Ortiz", "clave_hash": "PENDIENTE_DE_CONFIGURAR", "empleado_id": 2, "nombre_usuario": "daniel.repostero", "ultimo_intento": null, "intentos_fallidos": 0}
3	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla empleado. Registro ID: 3.	\N	{"nombre": "Vicente", "rol_id": 3, "bloqueado": 1, "creado_en": "2026-11-18T11:28:44.160219", "ap_materno": "Temporal", "ap_paterno": "Gustavo", "clave_hash": "PENDIENTE_DE_CONFIGURAR", "empleado_id": 3, "nombre_usuario": "vicente.cajero", "ultimo_intento": null, "intentos_fallidos": 0}
4	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla empleado. Registro ID: 4.	\N	{"nombre": "Eliseo", "rol_id": 4, "bloqueado": 1, "creado_en": "2026-11-18T11:28:44.160219", "ap_materno": "Cortez", "ap_paterno": "Pacheco", "clave_hash": "PENDIENTE_DE_CONFIGURAR", "empleado_id": 4, "nombre_usuario": "eliseo.repartidor", "ultimo_intento": null, "intentos_fallidos": 0}
\.


--
-- TOC entry 5782 (class 0 OID 27271)
-- Dependencies: 282
-- Data for Name: backup_envio; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_envio (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5796 (class 0 OID 27341)
-- Dependencies: 296
-- Data for Name: backup_estado_agenda; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_estado_agenda (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5798 (class 0 OID 27351)
-- Dependencies: 298
-- Data for Name: backup_estado_anticipo; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_estado_anticipo (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5800 (class 0 OID 27361)
-- Dependencies: 300
-- Data for Name: backup_estado_compra; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_estado_compra (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5802 (class 0 OID 27371)
-- Dependencies: 302
-- Data for Name: backup_estado_pedido; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_estado_pedido (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5804 (class 0 OID 27381)
-- Dependencies: 304
-- Data for Name: backup_estado_venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_estado_venta (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5760 (class 0 OID 27161)
-- Dependencies: 260
-- Data for Name: backup_ingrediente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_ingrediente (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5764 (class 0 OID 27181)
-- Dependencies: 264
-- Data for Name: backup_inventario_producto; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_inventario_producto (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5766 (class 0 OID 27191)
-- Dependencies: 266
-- Data for Name: backup_lote_inventario; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_lote_inventario (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5806 (class 0 OID 27391)
-- Dependencies: 306
-- Data for Name: backup_metodo_pago; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_metodo_pago (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5780 (class 0 OID 27261)
-- Dependencies: 280
-- Data for Name: backup_pago_venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_pago_venta (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5808 (class 0 OID 27401)
-- Dependencies: 308
-- Data for Name: backup_paso_receta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_paso_receta (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5772 (class 0 OID 27221)
-- Dependencies: 272
-- Data for Name: backup_pedido; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_pedido (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5810 (class 0 OID 27411)
-- Dependencies: 310
-- Data for Name: backup_permiso; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_permiso (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
1	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 1.	\N	{"permiso_id": 1, "descripcion": "Consultar información de clientes.", "nombre_permiso": "CLIENTES_CONSULTAR"}
2	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 2.	\N	{"permiso_id": 2, "descripcion": "Realizar operaciones CRUD sobre clientes.", "nombre_permiso": "CLIENTES_GESTIONAR"}
3	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 3.	\N	{"permiso_id": 3, "descripcion": "Administrar los empleados del sistema.", "nombre_permiso": "EMPLEADOS_GESTIONAR"}
4	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 4.	\N	{"permiso_id": 4, "descripcion": "Consultar productos.", "nombre_permiso": "PRODUCTOS_CONSULTAR"}
5	2026-11-18 11:28:44.160219-06	5	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 5.	\N	{"permiso_id": 5, "descripcion": "Realizar operaciones CRUD sobre productos.", "nombre_permiso": "PRODUCTOS_GESTIONAR"}
6	2026-11-18 11:28:44.160219-06	6	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 6.	\N	{"permiso_id": 6, "descripcion": "Consultar ingredientes.", "nombre_permiso": "INGREDIENTES_CONSULTAR"}
7	2026-11-18 11:28:44.160219-06	7	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 7.	\N	{"permiso_id": 7, "descripcion": "Administrar ingredientes.", "nombre_permiso": "INGREDIENTES_GESTIONAR"}
8	2026-11-18 11:28:44.160219-06	8	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 8.	\N	{"permiso_id": 8, "descripcion": "Consultar inventarios y existencias.", "nombre_permiso": "INVENTARIO_CONSULTAR"}
9	2026-11-18 11:28:44.160219-06	9	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 9.	\N	{"permiso_id": 9, "descripcion": "Administrar inventarios y existencias.", "nombre_permiso": "INVENTARIO_GESTIONAR"}
10	2026-11-18 11:28:44.160219-06	10	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 10.	\N	{"permiso_id": 10, "descripcion": "Consultar compras y sus detalles.", "nombre_permiso": "COMPRAS_CONSULTAR"}
11	2026-11-18 11:28:44.160219-06	11	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 11.	\N	{"permiso_id": 11, "descripcion": "Administrar compras y sus detalles.", "nombre_permiso": "COMPRAS_GESTIONAR"}
12	2026-11-18 11:28:44.160219-06	12	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 12.	\N	{"permiso_id": 12, "descripcion": "Consultar pedidos.", "nombre_permiso": "PEDIDOS_CONSULTAR"}
13	2026-11-18 11:28:44.160219-06	13	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 13.	\N	{"permiso_id": 13, "descripcion": "Administrar pedidos.", "nombre_permiso": "PEDIDOS_GESTIONAR"}
14	2026-11-18 11:28:44.160219-06	14	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 14.	\N	{"permiso_id": 14, "descripcion": "Consultar ventas.", "nombre_permiso": "VENTAS_CONSULTAR"}
15	2026-11-18 11:28:44.160219-06	15	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 15.	\N	{"permiso_id": 15, "descripcion": "Administrar ventas.", "nombre_permiso": "VENTAS_GESTIONAR"}
16	2026-11-18 11:28:44.160219-06	16	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 16.	\N	{"permiso_id": 16, "descripcion": "Administrar pagos y anticipos.", "nombre_permiso": "PAGOS_GESTIONAR"}
17	2026-11-18 11:28:44.160219-06	17	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 17.	\N	{"permiso_id": 17, "descripcion": "Consultar envíos.", "nombre_permiso": "ENVIOS_CONSULTAR"}
18	2026-11-18 11:28:44.160219-06	18	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 18.	\N	{"permiso_id": 18, "descripcion": "Administrar envíos.", "nombre_permiso": "ENVIOS_GESTIONAR"}
19	2026-11-18 11:28:44.160219-06	19	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 19.	\N	{"permiso_id": 19, "descripcion": "Consultar la agenda.", "nombre_permiso": "AGENDA_CONSULTAR"}
20	2026-11-18 11:28:44.160219-06	20	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 20.	\N	{"permiso_id": 20, "descripcion": "Administrar la agenda.", "nombre_permiso": "AGENDA_GESTIONAR"}
21	2026-11-18 11:28:44.160219-06	21	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 21.	\N	{"permiso_id": 21, "descripcion": "Administrar roles y permisos.", "nombre_permiso": "ROLES_GESTIONAR"}
22	2026-11-18 11:28:44.160219-06	22	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 22.	\N	{"permiso_id": 22, "descripcion": "Consultar auditorías generales y financieras.", "nombre_permiso": "AUDITORIAS_CONSULTAR"}
23	2026-11-18 11:28:44.160219-06	23	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 23.	\N	{"permiso_id": 23, "descripcion": "Consultar recetas y pasos de elaboración.", "nombre_permiso": "RECETAS_CONSULTAR"}
24	2026-11-18 11:28:44.160219-06	24	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla permiso. Registro ID: 24.	\N	{"permiso_id": 24, "descripcion": "Administrar recetas y sus ingredientes.", "nombre_permiso": "RECETAS_GESTIONAR"}
\.


--
-- TOC entry 5812 (class 0 OID 27421)
-- Dependencies: 312
-- Data for Name: backup_prioridad; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_prioridad (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5762 (class 0 OID 27171)
-- Dependencies: 262
-- Data for Name: backup_producto; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_producto (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5758 (class 0 OID 27151)
-- Dependencies: 258
-- Data for Name: backup_proveedor; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_proveedor (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5814 (class 0 OID 27431)
-- Dependencies: 314
-- Data for Name: backup_receta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_receta (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5816 (class 0 OID 27441)
-- Dependencies: 316
-- Data for Name: backup_receta_ingrediente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_receta_ingrediente (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5818 (class 0 OID 27451)
-- Dependencies: 318
-- Data for Name: backup_rol; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_rol (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
1	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol. Registro ID: 1.	\N	{"rol_id": 1, "nombre_rol": "ADMINISTRADOR", "descripcion": "Acceso completo a la administración del sistema Vanabby."}
2	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol. Registro ID: 2.	\N	{"rol_id": 2, "nombre_rol": "REPOSTERO", "descripcion": "Gestión de productos, ingredientes, recetas y actividades de producción."}
3	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol. Registro ID: 3.	\N	{"rol_id": 3, "nombre_rol": "CAJERO", "descripcion": "Gestión de clientes, pedidos, ventas, pagos y anticipos."}
4	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol. Registro ID: 4.	\N	{"rol_id": 4, "nombre_rol": "REPARTIDOR", "descripcion": "Gestión de envíos y consulta de información necesaria para las entregas."}
\.


--
-- TOC entry 5820 (class 0 OID 27461)
-- Dependencies: 320
-- Data for Name: backup_rol_permiso; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_rol_permiso (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
1	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 1}
2	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 2}
3	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 3}
4	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 4}
5	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 5}
6	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 6}
7	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 7}
8	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 8}
9	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 9}
10	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 10}
11	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 11}
12	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 12}
13	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 13}
14	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 14}
15	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 15}
16	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 16}
17	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 17}
18	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 18}
19	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 19}
20	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 20}
21	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 21}
22	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 22}
23	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 23}
24	2026-11-18 11:28:44.160219-06	1	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 1.	\N	{"rol_id": 1, "permiso_id": 24}
25	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 4}
26	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 5}
27	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 6}
28	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 7}
29	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 8}
30	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 9}
31	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 10}
32	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 12}
33	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 19}
34	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 23}
35	2026-11-18 11:28:44.160219-06	2	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 2.	\N	{"rol_id": 2, "permiso_id": 24}
36	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 1}
37	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 2}
38	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 4}
39	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 8}
40	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 10}
41	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 12}
42	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 13}
43	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 14}
44	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 15}
45	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 16}
46	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 17}
47	2026-11-18 11:28:44.160219-06	3	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 3.	\N	{"rol_id": 3, "permiso_id": 19}
48	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 4.	\N	{"rol_id": 4, "permiso_id": 1}
49	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 4.	\N	{"rol_id": 4, "permiso_id": 4}
50	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 4.	\N	{"rol_id": 4, "permiso_id": 12}
51	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 4.	\N	{"rol_id": 4, "permiso_id": 17}
52	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 4.	\N	{"rol_id": 4, "permiso_id": 18}
53	2026-11-18 11:28:44.160219-06	4	\N	\N	INSERT	Operacion INSERT realizada sobre la tabla rol_permiso. Registro ID: 4.	\N	{"rol_id": 4, "permiso_id": 19}
\.


--
-- TOC entry 5822 (class 0 OID 27471)
-- Dependencies: 322
-- Data for Name: backup_unidad_medida; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_unidad_medida (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5774 (class 0 OID 27231)
-- Dependencies: 274
-- Data for Name: backup_venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.backup_venta (backup_id, fecha_respaldo, id_registro_original, empleado_id, nombre_empleado, operacion, descripcion, datos_anteriores, datos_nuevos) FROM stdin;
\.


--
-- TOC entry 5720 (class 0 OID 26716)
-- Dependencies: 220
-- Data for Name: bloqueo; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.bloqueo (bloqueo_id, empleado_id, cliente_id, fecha_bloqueo, intentos_acumulados, desbloqueado_por_empleado_id, fecha_desbloqueo, motivo) FROM stdin;
\.


--
-- TOC entry 5721 (class 0 OID 26721)
-- Dependencies: 221
-- Data for Name: categoria; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.categoria (categoria_id, nombre_categoria) FROM stdin;
\.


--
-- TOC entry 5722 (class 0 OID 26724)
-- Dependencies: 222
-- Data for Name: cliente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.cliente (cliente_id, nombre, ap_paterno, ap_materno, telefono, correo, creado_en) FROM stdin;
1	oVQJPL0x3L9oBmPlMfPocf6uw/3n0NQpc4BxcF1GwcuQMg==	AxYB8ytQcgTn4M3s/hsaxV5zrI/iqPm4nLRF0yL2FrUBLNUcSnOuSw==	dQjwviz0csq+2aWyhlFJhlLGZtj89/KTf+58VtmfHspONRhW	TGboG5wu869VR/rTx4juzYyLXhNLCGowFDzGAKtjKxPXjVRvIvw=	DEXsIXY6AxfJLy1/Uye0GM8IBU7bbos4a8maCt8GtZf9k89FIZV7XsJIvAC9vn51RZsCwCZe	2026-11-23 20:33:20.724218
2	HF2CVhO52Nsb4EvAGukX6DTkcgTZ6ewq3lFd3zZeQvFpcA==	7s9qFwsNTfC8+mkliuDD1hJGnGzGfVfOwXFtWTTWwteppIZl0b0REQ==	kuKCIgse0T0TGZG+5u/ufrb/lNvpmJRGJet8TQ9zb5hNSNzc	u+0DJRSzw434Jbhm+IOLxDWwQj+RvFM8rTJQ/pnDUjATE8TOmzg=	jhuZYQ+vYbujOMqCFIbSUTcykdXzorcmZEeWjNob0elD0M/lwoq8x9WR9o7YPBaHgKUNThXA	2026-11-23 20:36:09.110787
3	kXyEh00s3hFuofs/5/lDahQiB/0ODYp9GBelcnspPHvmrw==	91N2/XtlxVCP8iwfYgI3sNJY1ShFDCJn5iO7GK9S0FTxTIVff5g4og==	fC3mllIdGfJ87tfV+3OeIOH81S5zKi17sieB9LRUHxbuAVHM	0UqrwyT9a3xJLU6iXh14+pgbwuNkX/AyW9TzgUIlYNfs0UAbsOI=	3EaByx48QKsSWBhHlvyyzrnHBL/ydEjbg7jGraVY1e9JWKntp+lsQzLJYDixUouu9eo4Ma9o	2026-11-23 20:36:23.498136
123	2bWtd6oYnu34xWpGuo8FFRXkPa8QNY6dgEqFWMr9qYnk	gYGk+79hnzrXVxEVryujQB5ONfQP0MgneWzUFJ/jdcA=	TrF0rPIkSFVL9bp3cPX2C6IbSssjb39bitjgU2XrDBU=	J8VF2o+XN/YRSoAicKKZkuyVbhw+daX6rFIC8zMzhmaKbP7JTvo=	gubsekaFrAoLVhYJ9O0kDiP6c6+bczRPhvnoTcNivRUZiyutmQbFIfSeGTw0l5kHJuOLIHI=	2026-11-24 11:23:52.150351
\.


--
-- TOC entry 5723 (class 0 OID 26727)
-- Dependencies: 223
-- Data for Name: compra; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.compra (compra_id, proveedor_id, creado_en, fecha_esperada, estado_compra_id) FROM stdin;
\.


--
-- TOC entry 5724 (class 0 OID 26730)
-- Dependencies: 224
-- Data for Name: detalle_compra; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.detalle_compra (detalle_compra_id, compra_id, ingrediente_id, cantidad, precio_unitario, subtotal) FROM stdin;
\.


--
-- TOC entry 5725 (class 0 OID 26733)
-- Dependencies: 225
-- Data for Name: detalle_venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.detalle_venta (detalle_venta_id, venta_id, producto_id, cantidad, precio_unitario, subtotal) FROM stdin;
\.


--
-- TOC entry 5726 (class 0 OID 26736)
-- Dependencies: 226
-- Data for Name: direccion_cliente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.direccion_cliente (direccion_id, cliente_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) FROM stdin;
\.


--
-- TOC entry 5727 (class 0 OID 26739)
-- Dependencies: 227
-- Data for Name: direccion_empleado; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.direccion_empleado (direccion_id, empleado_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) FROM stdin;
\.


--
-- TOC entry 5728 (class 0 OID 26742)
-- Dependencies: 228
-- Data for Name: direccion_proveedor; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.direccion_proveedor (direccion_id, proveedor_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) FROM stdin;
\.


--
-- TOC entry 5729 (class 0 OID 26745)
-- Dependencies: 229
-- Data for Name: empleado; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.empleado (empleado_id, nombre_usuario, clave_hash, nombre, ap_paterno, ap_materno, rol_id, bloqueado, intentos_fallidos, ultimo_intento, creado_en) FROM stdin;
1	admin_pzu	PENDIENTE_DE_CONFIGURAR	PZU	Mata	Ramirez	1	1	0	\N	2026-11-18 11:28:44.160219
2	daniel.repostero	PENDIENTE_DE_CONFIGURAR	Daniel	Ortiz	De la Cruz	2	1	0	\N	2026-11-18 11:28:44.160219
3	vicente.cajero	PENDIENTE_DE_CONFIGURAR	Vicente	Gustavo	Temporal	3	1	0	\N	2026-11-18 11:28:44.160219
4	eliseo.repartidor	PENDIENTE_DE_CONFIGURAR	Eliseo	Pacheco	Cortez	4	1	0	\N	2026-11-18 11:28:44.160219
\.


--
-- TOC entry 5730 (class 0 OID 26750)
-- Dependencies: 230
-- Data for Name: envio; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.envio (envio_id, pedido_id, direccion_id, empleado_id, costo_envio, fecha_salida, fecha_entrega_real, notas) FROM stdin;
\.


--
-- TOC entry 5731 (class 0 OID 26755)
-- Dependencies: 231
-- Data for Name: estado_agenda; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.estado_agenda (estado_agenda_id, nombre_estado) FROM stdin;
\.


--
-- TOC entry 5732 (class 0 OID 26758)
-- Dependencies: 232
-- Data for Name: estado_anticipo; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.estado_anticipo (estado_anticipo_id, nombre_estado) FROM stdin;
\.


--
-- TOC entry 5733 (class 0 OID 26761)
-- Dependencies: 233
-- Data for Name: estado_compra; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.estado_compra (estado_compra_id, nombre_estado) FROM stdin;
\.


--
-- TOC entry 5734 (class 0 OID 26764)
-- Dependencies: 234
-- Data for Name: estado_pedido; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.estado_pedido (estado_pedido_id, nombre_estado) FROM stdin;
\.


--
-- TOC entry 5735 (class 0 OID 26767)
-- Dependencies: 235
-- Data for Name: estado_venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.estado_venta (estado_venta_id, nombre_estado) FROM stdin;
\.


--
-- TOC entry 5736 (class 0 OID 26770)
-- Dependencies: 236
-- Data for Name: ingrediente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.ingrediente (ingrediente_id, nombre, unidad_medida_id, costo_por_unidad) FROM stdin;
\.


--
-- TOC entry 5737 (class 0 OID 26773)
-- Dependencies: 237
-- Data for Name: inventario_producto; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.inventario_producto (inv_producto_id, producto_id, stock_disponible, stock_minimo, actualizado_en) FROM stdin;
\.


--
-- TOC entry 5738 (class 0 OID 26776)
-- Dependencies: 238
-- Data for Name: lote_inventario; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.lote_inventario (lote_id, ingrediente_id, numero_lote, cantidad, unidad_medida_id, fecha_caducidad, creado_en) FROM stdin;
\.


--
-- TOC entry 5739 (class 0 OID 26779)
-- Dependencies: 239
-- Data for Name: metodo_pago; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.metodo_pago (metodo_pago_id, nombre_metodo) FROM stdin;
\.


--
-- TOC entry 5740 (class 0 OID 26782)
-- Dependencies: 240
-- Data for Name: pago_venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.pago_venta (pago_venta_id, venta_id, metodo_pago_id, monto, pagado_en, registrado_por) FROM stdin;
\.


--
-- TOC entry 5741 (class 0 OID 26785)
-- Dependencies: 241
-- Data for Name: paso_receta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.paso_receta (paso_id, receta_id, numero_paso, descripcion) FROM stdin;
\.


--
-- TOC entry 5742 (class 0 OID 26788)
-- Dependencies: 242
-- Data for Name: pedido; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.pedido (pedido_id, cliente_id, empleado_id, estado_pedido_id, prioridad_id, fecha_pedido, fecha_entrega_programada) FROM stdin;
\.


--
-- TOC entry 5743 (class 0 OID 26791)
-- Dependencies: 243
-- Data for Name: permiso; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.permiso (permiso_id, nombre_permiso, descripcion) FROM stdin;
1	CLIENTES_CONSULTAR	Consultar información de clientes.
2	CLIENTES_GESTIONAR	Realizar operaciones CRUD sobre clientes.
3	EMPLEADOS_GESTIONAR	Administrar los empleados del sistema.
4	PRODUCTOS_CONSULTAR	Consultar productos.
5	PRODUCTOS_GESTIONAR	Realizar operaciones CRUD sobre productos.
6	INGREDIENTES_CONSULTAR	Consultar ingredientes.
7	INGREDIENTES_GESTIONAR	Administrar ingredientes.
8	INVENTARIO_CONSULTAR	Consultar inventarios y existencias.
9	INVENTARIO_GESTIONAR	Administrar inventarios y existencias.
10	COMPRAS_CONSULTAR	Consultar compras y sus detalles.
11	COMPRAS_GESTIONAR	Administrar compras y sus detalles.
12	PEDIDOS_CONSULTAR	Consultar pedidos.
13	PEDIDOS_GESTIONAR	Administrar pedidos.
14	VENTAS_CONSULTAR	Consultar ventas.
15	VENTAS_GESTIONAR	Administrar ventas.
16	PAGOS_GESTIONAR	Administrar pagos y anticipos.
17	ENVIOS_CONSULTAR	Consultar envíos.
18	ENVIOS_GESTIONAR	Administrar envíos.
19	AGENDA_CONSULTAR	Consultar la agenda.
20	AGENDA_GESTIONAR	Administrar la agenda.
21	ROLES_GESTIONAR	Administrar roles y permisos.
22	AUDITORIAS_CONSULTAR	Consultar auditorías generales y financieras.
23	RECETAS_CONSULTAR	Consultar recetas y pasos de elaboración.
24	RECETAS_GESTIONAR	Administrar recetas y sus ingredientes.
\.


--
-- TOC entry 5744 (class 0 OID 26796)
-- Dependencies: 244
-- Data for Name: prioridad; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.prioridad (prioridad_id, nombre_prioridad) FROM stdin;
\.


--
-- TOC entry 5745 (class 0 OID 26799)
-- Dependencies: 245
-- Data for Name: producto; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.producto (producto_id, sku, nombre, descripcion, imagen, categoria_id, precio, tiempo_preparacion_min, creado_en) FROM stdin;
\.


--
-- TOC entry 5746 (class 0 OID 26804)
-- Dependencies: 246
-- Data for Name: proveedor; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.proveedor (proveedor_id, nombre, contacto_nombre, contacto_ap_paterno, contacto_ap_materno, telefono, correo, notas) FROM stdin;
\.


--
-- TOC entry 5747 (class 0 OID 26809)
-- Dependencies: 247
-- Data for Name: receta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.receta (receta_id, producto_id, rendimiento, tiempo_estimado_min) FROM stdin;
\.


--
-- TOC entry 5748 (class 0 OID 26812)
-- Dependencies: 248
-- Data for Name: receta_ingrediente; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.receta_ingrediente (receta_id, ingrediente_id, cantidad) FROM stdin;
\.


--
-- TOC entry 5749 (class 0 OID 26815)
-- Dependencies: 249
-- Data for Name: rol; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.rol (rol_id, nombre_rol, descripcion) FROM stdin;
1	ADMINISTRADOR	Acceso completo a la administración del sistema Vanabby.
2	REPOSTERO	Gestión de productos, ingredientes, recetas y actividades de producción.
3	CAJERO	Gestión de clientes, pedidos, ventas, pagos y anticipos.
4	REPARTIDOR	Gestión de envíos y consulta de información necesaria para las entregas.
\.


--
-- TOC entry 5750 (class 0 OID 26820)
-- Dependencies: 250
-- Data for Name: rol_permiso; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.rol_permiso (rol_id, permiso_id) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	10
1	11
1	12
1	13
1	14
1	15
1	16
1	17
1	18
1	19
1	20
1	21
1	22
1	23
1	24
2	4
2	5
2	6
2	7
2	8
2	9
2	10
2	12
2	19
2	23
2	24
3	1
3	2
3	4
3	8
3	10
3	12
3	13
3	14
3	15
3	16
3	17
3	19
4	1
4	4
4	12
4	17
4	18
4	19
\.


--
-- TOC entry 5751 (class 0 OID 26823)
-- Dependencies: 251
-- Data for Name: unidad_medida; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.unidad_medida (unidad_medida_id, simbolo, descripcion) FROM stdin;
\.


--
-- TOC entry 5752 (class 0 OID 26826)
-- Dependencies: 252
-- Data for Name: venta; Type: TABLE DATA; Schema: vanabby; Owner: postgres
--

COPY vanabby.venta (venta_id, empleado_id, cliente_id, metodo_pago_id, estado_venta_id, pedido_id, fecha_venta, fecha_entrega_programada, total) FROM stdin;
\.


--
-- TOC entry 5836 (class 0 OID 0)
-- Dependencies: 335
-- Name: auditoria_financiera_auditoria_financiera_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.auditoria_financiera_auditoria_financiera_id_seq', 1, false);


--
-- TOC entry 5837 (class 0 OID 0)
-- Dependencies: 333
-- Name: auditoria_general_auditoria_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.auditoria_general_auditoria_id_seq', 100, true);


--
-- TOC entry 5838 (class 0 OID 0)
-- Dependencies: 287
-- Name: backup_agenda_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_agenda_backup_id_seq', 1, false);


--
-- TOC entry 5839 (class 0 OID 0)
-- Dependencies: 277
-- Name: backup_anticipo_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_anticipo_backup_id_seq', 1, false);


--
-- TOC entry 5840 (class 0 OID 0)
-- Dependencies: 339
-- Name: backup_auditoria_financiera_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_auditoria_financiera_backup_id_seq', 1, false);


--
-- TOC entry 5841 (class 0 OID 0)
-- Dependencies: 337
-- Name: backup_auditoria_general_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_auditoria_general_backup_id_seq', 100, true);


--
-- TOC entry 5842 (class 0 OID 0)
-- Dependencies: 289
-- Name: backup_bloqueo_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_bloqueo_backup_id_seq', 1, false);


--
-- TOC entry 5843 (class 0 OID 0)
-- Dependencies: 291
-- Name: backup_categoria_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_categoria_backup_id_seq', 1, false);


--
-- TOC entry 5844 (class 0 OID 0)
-- Dependencies: 253
-- Name: backup_cliente_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_cliente_backup_id_seq', 15, true);


--
-- TOC entry 5845 (class 0 OID 0)
-- Dependencies: 267
-- Name: backup_compra_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_compra_backup_id_seq', 1, false);


--
-- TOC entry 5846 (class 0 OID 0)
-- Dependencies: 269
-- Name: backup_detalle_compra_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_detalle_compra_backup_id_seq', 1, false);


--
-- TOC entry 5847 (class 0 OID 0)
-- Dependencies: 275
-- Name: backup_detalle_venta_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_detalle_venta_backup_id_seq', 1, false);


--
-- TOC entry 5848 (class 0 OID 0)
-- Dependencies: 283
-- Name: backup_direccion_cliente_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_direccion_cliente_backup_id_seq', 1, false);


--
-- TOC entry 5849 (class 0 OID 0)
-- Dependencies: 293
-- Name: backup_direccion_empleado_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_direccion_empleado_backup_id_seq', 1, false);


--
-- TOC entry 5850 (class 0 OID 0)
-- Dependencies: 285
-- Name: backup_direccion_proveedor_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_direccion_proveedor_backup_id_seq', 1, false);


--
-- TOC entry 5851 (class 0 OID 0)
-- Dependencies: 255
-- Name: backup_empleado_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_empleado_backup_id_seq', 4, true);


--
-- TOC entry 5852 (class 0 OID 0)
-- Dependencies: 281
-- Name: backup_envio_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_envio_backup_id_seq', 1, false);


--
-- TOC entry 5853 (class 0 OID 0)
-- Dependencies: 295
-- Name: backup_estado_agenda_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_estado_agenda_backup_id_seq', 1, false);


--
-- TOC entry 5854 (class 0 OID 0)
-- Dependencies: 297
-- Name: backup_estado_anticipo_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_estado_anticipo_backup_id_seq', 1, false);


--
-- TOC entry 5855 (class 0 OID 0)
-- Dependencies: 299
-- Name: backup_estado_compra_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_estado_compra_backup_id_seq', 1, false);


--
-- TOC entry 5856 (class 0 OID 0)
-- Dependencies: 301
-- Name: backup_estado_pedido_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_estado_pedido_backup_id_seq', 1, false);


--
-- TOC entry 5857 (class 0 OID 0)
-- Dependencies: 303
-- Name: backup_estado_venta_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_estado_venta_backup_id_seq', 1, false);


--
-- TOC entry 5858 (class 0 OID 0)
-- Dependencies: 259
-- Name: backup_ingrediente_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_ingrediente_backup_id_seq', 1, false);


--
-- TOC entry 5859 (class 0 OID 0)
-- Dependencies: 263
-- Name: backup_inventario_producto_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_inventario_producto_backup_id_seq', 1, false);


--
-- TOC entry 5860 (class 0 OID 0)
-- Dependencies: 265
-- Name: backup_lote_inventario_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_lote_inventario_backup_id_seq', 1, false);


--
-- TOC entry 5861 (class 0 OID 0)
-- Dependencies: 305
-- Name: backup_metodo_pago_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_metodo_pago_backup_id_seq', 1, false);


--
-- TOC entry 5862 (class 0 OID 0)
-- Dependencies: 279
-- Name: backup_pago_venta_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_pago_venta_backup_id_seq', 1, false);


--
-- TOC entry 5863 (class 0 OID 0)
-- Dependencies: 307
-- Name: backup_paso_receta_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_paso_receta_backup_id_seq', 1, false);


--
-- TOC entry 5864 (class 0 OID 0)
-- Dependencies: 271
-- Name: backup_pedido_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_pedido_backup_id_seq', 1, false);


--
-- TOC entry 5865 (class 0 OID 0)
-- Dependencies: 309
-- Name: backup_permiso_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_permiso_backup_id_seq', 24, true);


--
-- TOC entry 5866 (class 0 OID 0)
-- Dependencies: 311
-- Name: backup_prioridad_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_prioridad_backup_id_seq', 1, false);


--
-- TOC entry 5867 (class 0 OID 0)
-- Dependencies: 261
-- Name: backup_producto_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_producto_backup_id_seq', 1, false);


--
-- TOC entry 5868 (class 0 OID 0)
-- Dependencies: 257
-- Name: backup_proveedor_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_proveedor_backup_id_seq', 1, false);


--
-- TOC entry 5869 (class 0 OID 0)
-- Dependencies: 313
-- Name: backup_receta_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_receta_backup_id_seq', 1, false);


--
-- TOC entry 5870 (class 0 OID 0)
-- Dependencies: 315
-- Name: backup_receta_ingrediente_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_receta_ingrediente_backup_id_seq', 1, false);


--
-- TOC entry 5871 (class 0 OID 0)
-- Dependencies: 317
-- Name: backup_rol_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_rol_backup_id_seq', 4, true);


--
-- TOC entry 5872 (class 0 OID 0)
-- Dependencies: 319
-- Name: backup_rol_permiso_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_rol_permiso_backup_id_seq', 53, true);


--
-- TOC entry 5873 (class 0 OID 0)
-- Dependencies: 321
-- Name: backup_unidad_medida_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_unidad_medida_backup_id_seq', 1, false);


--
-- TOC entry 5874 (class 0 OID 0)
-- Dependencies: 273
-- Name: backup_venta_backup_id_seq; Type: SEQUENCE SET; Schema: vanabby; Owner: postgres
--

SELECT pg_catalog.setval('vanabby.backup_venta_backup_id_seq', 1, false);


--
-- TOC entry 5238 (class 2606 OID 26830)
-- Name: agenda agenda_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (agenda_id);


--
-- TOC entry 5240 (class 2606 OID 26832)
-- Name: anticipo anticipo_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.anticipo
    ADD CONSTRAINT anticipo_pkey PRIMARY KEY (anticipo_id);


--
-- TOC entry 5418 (class 2606 OID 27863)
-- Name: auditoria_financiera auditoria_financiera_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.auditoria_financiera
    ADD CONSTRAINT auditoria_financiera_pkey PRIMARY KEY (auditoria_financiera_id);


--
-- TOC entry 5413 (class 2606 OID 27853)
-- Name: auditoria_general auditoria_general_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.auditoria_general
    ADD CONSTRAINT auditoria_general_pkey PRIMARY KEY (auditoria_id);


--
-- TOC entry 5359 (class 2606 OID 27309)
-- Name: backup_agenda backup_agenda_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_agenda
    ADD CONSTRAINT backup_agenda_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5344 (class 2606 OID 27259)
-- Name: backup_anticipo backup_anticipo_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_anticipo
    ADD CONSTRAINT backup_anticipo_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5426 (class 2606 OID 27881)
-- Name: backup_auditoria_financiera backup_auditoria_financiera_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_auditoria_financiera
    ADD CONSTRAINT backup_auditoria_financiera_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5423 (class 2606 OID 27872)
-- Name: backup_auditoria_general backup_auditoria_general_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_auditoria_general
    ADD CONSTRAINT backup_auditoria_general_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5362 (class 2606 OID 27319)
-- Name: backup_bloqueo backup_bloqueo_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_bloqueo
    ADD CONSTRAINT backup_bloqueo_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5365 (class 2606 OID 27329)
-- Name: backup_categoria backup_categoria_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_categoria
    ADD CONSTRAINT backup_categoria_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5308 (class 2606 OID 27139)
-- Name: backup_cliente backup_cliente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_cliente
    ADD CONSTRAINT backup_cliente_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5329 (class 2606 OID 27209)
-- Name: backup_compra backup_compra_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_compra
    ADD CONSTRAINT backup_compra_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5332 (class 2606 OID 27219)
-- Name: backup_detalle_compra backup_detalle_compra_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_detalle_compra
    ADD CONSTRAINT backup_detalle_compra_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5341 (class 2606 OID 27249)
-- Name: backup_detalle_venta backup_detalle_venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_detalle_venta
    ADD CONSTRAINT backup_detalle_venta_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5353 (class 2606 OID 27289)
-- Name: backup_direccion_cliente backup_direccion_cliente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_direccion_cliente
    ADD CONSTRAINT backup_direccion_cliente_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5368 (class 2606 OID 27339)
-- Name: backup_direccion_empleado backup_direccion_empleado_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_direccion_empleado
    ADD CONSTRAINT backup_direccion_empleado_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5356 (class 2606 OID 27299)
-- Name: backup_direccion_proveedor backup_direccion_proveedor_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_direccion_proveedor
    ADD CONSTRAINT backup_direccion_proveedor_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5311 (class 2606 OID 27149)
-- Name: backup_empleado backup_empleado_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_empleado
    ADD CONSTRAINT backup_empleado_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5350 (class 2606 OID 27279)
-- Name: backup_envio backup_envio_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_envio
    ADD CONSTRAINT backup_envio_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5371 (class 2606 OID 27349)
-- Name: backup_estado_agenda backup_estado_agenda_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_estado_agenda
    ADD CONSTRAINT backup_estado_agenda_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5374 (class 2606 OID 27359)
-- Name: backup_estado_anticipo backup_estado_anticipo_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_estado_anticipo
    ADD CONSTRAINT backup_estado_anticipo_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5377 (class 2606 OID 27369)
-- Name: backup_estado_compra backup_estado_compra_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_estado_compra
    ADD CONSTRAINT backup_estado_compra_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5380 (class 2606 OID 27379)
-- Name: backup_estado_pedido backup_estado_pedido_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_estado_pedido
    ADD CONSTRAINT backup_estado_pedido_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5383 (class 2606 OID 27389)
-- Name: backup_estado_venta backup_estado_venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_estado_venta
    ADD CONSTRAINT backup_estado_venta_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5317 (class 2606 OID 27169)
-- Name: backup_ingrediente backup_ingrediente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_ingrediente
    ADD CONSTRAINT backup_ingrediente_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5323 (class 2606 OID 27189)
-- Name: backup_inventario_producto backup_inventario_producto_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_inventario_producto
    ADD CONSTRAINT backup_inventario_producto_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5326 (class 2606 OID 27199)
-- Name: backup_lote_inventario backup_lote_inventario_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_lote_inventario
    ADD CONSTRAINT backup_lote_inventario_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5386 (class 2606 OID 27399)
-- Name: backup_metodo_pago backup_metodo_pago_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_metodo_pago
    ADD CONSTRAINT backup_metodo_pago_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5347 (class 2606 OID 27269)
-- Name: backup_pago_venta backup_pago_venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_pago_venta
    ADD CONSTRAINT backup_pago_venta_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5389 (class 2606 OID 27409)
-- Name: backup_paso_receta backup_paso_receta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_paso_receta
    ADD CONSTRAINT backup_paso_receta_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5335 (class 2606 OID 27229)
-- Name: backup_pedido backup_pedido_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_pedido
    ADD CONSTRAINT backup_pedido_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5392 (class 2606 OID 27419)
-- Name: backup_permiso backup_permiso_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_permiso
    ADD CONSTRAINT backup_permiso_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5395 (class 2606 OID 27429)
-- Name: backup_prioridad backup_prioridad_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_prioridad
    ADD CONSTRAINT backup_prioridad_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5320 (class 2606 OID 27179)
-- Name: backup_producto backup_producto_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_producto
    ADD CONSTRAINT backup_producto_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5314 (class 2606 OID 27159)
-- Name: backup_proveedor backup_proveedor_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_proveedor
    ADD CONSTRAINT backup_proveedor_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5401 (class 2606 OID 27449)
-- Name: backup_receta_ingrediente backup_receta_ingrediente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_receta_ingrediente
    ADD CONSTRAINT backup_receta_ingrediente_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5398 (class 2606 OID 27439)
-- Name: backup_receta backup_receta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_receta
    ADD CONSTRAINT backup_receta_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5407 (class 2606 OID 27469)
-- Name: backup_rol_permiso backup_rol_permiso_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_rol_permiso
    ADD CONSTRAINT backup_rol_permiso_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5404 (class 2606 OID 27459)
-- Name: backup_rol backup_rol_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_rol
    ADD CONSTRAINT backup_rol_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5410 (class 2606 OID 27479)
-- Name: backup_unidad_medida backup_unidad_medida_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_unidad_medida
    ADD CONSTRAINT backup_unidad_medida_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5338 (class 2606 OID 27239)
-- Name: backup_venta backup_venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.backup_venta
    ADD CONSTRAINT backup_venta_pkey PRIMARY KEY (backup_id);


--
-- TOC entry 5242 (class 2606 OID 26834)
-- Name: bloqueo bloqueo_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.bloqueo
    ADD CONSTRAINT bloqueo_pkey PRIMARY KEY (bloqueo_id);


--
-- TOC entry 5244 (class 2606 OID 26836)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (categoria_id);


--
-- TOC entry 5246 (class 2606 OID 26838)
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (cliente_id);


--
-- TOC entry 5248 (class 2606 OID 26840)
-- Name: compra compra_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.compra
    ADD CONSTRAINT compra_pkey PRIMARY KEY (compra_id);


--
-- TOC entry 5250 (class 2606 OID 26842)
-- Name: detalle_compra detalle_compra_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.detalle_compra
    ADD CONSTRAINT detalle_compra_pkey PRIMARY KEY (detalle_compra_id);


--
-- TOC entry 5252 (class 2606 OID 26844)
-- Name: detalle_venta detalle_venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.detalle_venta
    ADD CONSTRAINT detalle_venta_pkey PRIMARY KEY (detalle_venta_id);


--
-- TOC entry 5254 (class 2606 OID 26846)
-- Name: direccion_cliente direccion_cliente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.direccion_cliente
    ADD CONSTRAINT direccion_cliente_pkey PRIMARY KEY (direccion_id);


--
-- TOC entry 5256 (class 2606 OID 26848)
-- Name: direccion_empleado direccion_empleado_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.direccion_empleado
    ADD CONSTRAINT direccion_empleado_pkey PRIMARY KEY (direccion_id);


--
-- TOC entry 5258 (class 2606 OID 26850)
-- Name: direccion_proveedor direccion_proveedor_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.direccion_proveedor
    ADD CONSTRAINT direccion_proveedor_pkey PRIMARY KEY (direccion_id);


--
-- TOC entry 5260 (class 2606 OID 26852)
-- Name: empleado empleado_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (empleado_id);


--
-- TOC entry 5262 (class 2606 OID 26854)
-- Name: envio envio_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.envio
    ADD CONSTRAINT envio_pkey PRIMARY KEY (envio_id);


--
-- TOC entry 5264 (class 2606 OID 26856)
-- Name: estado_agenda estado_agenda_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.estado_agenda
    ADD CONSTRAINT estado_agenda_pkey PRIMARY KEY (estado_agenda_id);


--
-- TOC entry 5266 (class 2606 OID 26858)
-- Name: estado_anticipo estado_anticipo_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.estado_anticipo
    ADD CONSTRAINT estado_anticipo_pkey PRIMARY KEY (estado_anticipo_id);


--
-- TOC entry 5268 (class 2606 OID 26860)
-- Name: estado_compra estado_compra_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.estado_compra
    ADD CONSTRAINT estado_compra_pkey PRIMARY KEY (estado_compra_id);


--
-- TOC entry 5270 (class 2606 OID 26862)
-- Name: estado_pedido estado_pedido_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.estado_pedido
    ADD CONSTRAINT estado_pedido_pkey PRIMARY KEY (estado_pedido_id);


--
-- TOC entry 5272 (class 2606 OID 26864)
-- Name: estado_venta estado_venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.estado_venta
    ADD CONSTRAINT estado_venta_pkey PRIMARY KEY (estado_venta_id);


--
-- TOC entry 5274 (class 2606 OID 26866)
-- Name: ingrediente ingrediente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.ingrediente
    ADD CONSTRAINT ingrediente_pkey PRIMARY KEY (ingrediente_id);


--
-- TOC entry 5276 (class 2606 OID 26868)
-- Name: inventario_producto inventario_producto_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.inventario_producto
    ADD CONSTRAINT inventario_producto_pkey PRIMARY KEY (inv_producto_id);


--
-- TOC entry 5278 (class 2606 OID 26870)
-- Name: lote_inventario lote_inventario_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.lote_inventario
    ADD CONSTRAINT lote_inventario_pkey PRIMARY KEY (lote_id);


--
-- TOC entry 5280 (class 2606 OID 26872)
-- Name: metodo_pago metodo_pago_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.metodo_pago
    ADD CONSTRAINT metodo_pago_pkey PRIMARY KEY (metodo_pago_id);


--
-- TOC entry 5282 (class 2606 OID 26874)
-- Name: pago_venta pago_venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pago_venta
    ADD CONSTRAINT pago_venta_pkey PRIMARY KEY (pago_venta_id);


--
-- TOC entry 5284 (class 2606 OID 26876)
-- Name: paso_receta paso_receta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.paso_receta
    ADD CONSTRAINT paso_receta_pkey PRIMARY KEY (paso_id);


--
-- TOC entry 5286 (class 2606 OID 26878)
-- Name: pedido pedido_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (pedido_id);


--
-- TOC entry 5288 (class 2606 OID 26880)
-- Name: permiso permiso_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.permiso
    ADD CONSTRAINT permiso_pkey PRIMARY KEY (permiso_id);


--
-- TOC entry 5290 (class 2606 OID 26882)
-- Name: prioridad prioridad_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.prioridad
    ADD CONSTRAINT prioridad_pkey PRIMARY KEY (prioridad_id);


--
-- TOC entry 5292 (class 2606 OID 26884)
-- Name: producto producto_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (producto_id);


--
-- TOC entry 5294 (class 2606 OID 26886)
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (proveedor_id);


--
-- TOC entry 5298 (class 2606 OID 26888)
-- Name: receta_ingrediente receta_ingrediente_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.receta_ingrediente
    ADD CONSTRAINT receta_ingrediente_pkey PRIMARY KEY (receta_id, ingrediente_id);


--
-- TOC entry 5296 (class 2606 OID 26890)
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (receta_id);


--
-- TOC entry 5302 (class 2606 OID 26892)
-- Name: rol_permiso rol_permiso_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.rol_permiso
    ADD CONSTRAINT rol_permiso_pkey PRIMARY KEY (rol_id, permiso_id);


--
-- TOC entry 5300 (class 2606 OID 26894)
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (rol_id);


--
-- TOC entry 5304 (class 2606 OID 26896)
-- Name: unidad_medida unidad_medida_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.unidad_medida
    ADD CONSTRAINT unidad_medida_pkey PRIMARY KEY (unidad_medida_id);


--
-- TOC entry 5306 (class 2606 OID 26898)
-- Name: venta venta_pkey; Type: CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.venta
    ADD CONSTRAINT venta_pkey PRIMARY KEY (venta_id);


--
-- TOC entry 5419 (class 1259 OID 27886)
-- Name: idx_auditoria_financiera_empleado; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_auditoria_financiera_empleado ON vanabby.auditoria_financiera USING btree (empleado_id);


--
-- TOC entry 5420 (class 1259 OID 27885)
-- Name: idx_auditoria_financiera_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_auditoria_financiera_fecha ON vanabby.auditoria_financiera USING btree (fecha_movimiento);


--
-- TOC entry 5421 (class 1259 OID 27887)
-- Name: idx_auditoria_financiera_tabla; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_auditoria_financiera_tabla ON vanabby.auditoria_financiera USING btree (tabla_afectada);


--
-- TOC entry 5414 (class 1259 OID 27883)
-- Name: idx_auditoria_general_empleado; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_auditoria_general_empleado ON vanabby.auditoria_general USING btree (empleado_id);


--
-- TOC entry 5415 (class 1259 OID 27882)
-- Name: idx_auditoria_general_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_auditoria_general_fecha ON vanabby.auditoria_general USING btree (fecha_movimiento);


--
-- TOC entry 5416 (class 1259 OID 27884)
-- Name: idx_auditoria_general_tabla; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_auditoria_general_tabla ON vanabby.auditoria_general USING btree (tabla_afectada);


--
-- TOC entry 5360 (class 1259 OID 27497)
-- Name: idx_backup_agenda_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_agenda_fecha ON vanabby.backup_agenda USING btree (fecha_respaldo);


--
-- TOC entry 5345 (class 1259 OID 27492)
-- Name: idx_backup_anticipo_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_anticipo_fecha ON vanabby.backup_anticipo USING btree (fecha_respaldo);


--
-- TOC entry 5427 (class 1259 OID 27889)
-- Name: idx_backup_auditoria_financiera_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_auditoria_financiera_fecha ON vanabby.backup_auditoria_financiera USING btree (fecha_respaldo);


--
-- TOC entry 5424 (class 1259 OID 27888)
-- Name: idx_backup_auditoria_general_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_auditoria_general_fecha ON vanabby.backup_auditoria_general USING btree (fecha_respaldo);


--
-- TOC entry 5363 (class 1259 OID 27498)
-- Name: idx_backup_bloqueo_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_bloqueo_fecha ON vanabby.backup_bloqueo USING btree (fecha_respaldo);


--
-- TOC entry 5366 (class 1259 OID 27499)
-- Name: idx_backup_categoria_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_categoria_fecha ON vanabby.backup_categoria USING btree (fecha_respaldo);


--
-- TOC entry 5309 (class 1259 OID 27480)
-- Name: idx_backup_cliente_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_cliente_fecha ON vanabby.backup_cliente USING btree (fecha_respaldo);


--
-- TOC entry 5330 (class 1259 OID 27487)
-- Name: idx_backup_compra_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_compra_fecha ON vanabby.backup_compra USING btree (fecha_respaldo);


--
-- TOC entry 5333 (class 1259 OID 27488)
-- Name: idx_backup_detalle_compra_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_detalle_compra_fecha ON vanabby.backup_detalle_compra USING btree (fecha_respaldo);


--
-- TOC entry 5342 (class 1259 OID 27491)
-- Name: idx_backup_detalle_venta_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_detalle_venta_fecha ON vanabby.backup_detalle_venta USING btree (fecha_respaldo);


--
-- TOC entry 5354 (class 1259 OID 27495)
-- Name: idx_backup_direccion_cliente_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_direccion_cliente_fecha ON vanabby.backup_direccion_cliente USING btree (fecha_respaldo);


--
-- TOC entry 5369 (class 1259 OID 27500)
-- Name: idx_backup_direccion_empleado_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_direccion_empleado_fecha ON vanabby.backup_direccion_empleado USING btree (fecha_respaldo);


--
-- TOC entry 5357 (class 1259 OID 27496)
-- Name: idx_backup_direccion_proveedor_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_direccion_proveedor_fecha ON vanabby.backup_direccion_proveedor USING btree (fecha_respaldo);


--
-- TOC entry 5312 (class 1259 OID 27481)
-- Name: idx_backup_empleado_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_empleado_fecha ON vanabby.backup_empleado USING btree (fecha_respaldo);


--
-- TOC entry 5351 (class 1259 OID 27494)
-- Name: idx_backup_envio_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_envio_fecha ON vanabby.backup_envio USING btree (fecha_respaldo);


--
-- TOC entry 5372 (class 1259 OID 27501)
-- Name: idx_backup_estado_agenda_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_estado_agenda_fecha ON vanabby.backup_estado_agenda USING btree (fecha_respaldo);


--
-- TOC entry 5375 (class 1259 OID 27502)
-- Name: idx_backup_estado_anticipo_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_estado_anticipo_fecha ON vanabby.backup_estado_anticipo USING btree (fecha_respaldo);


--
-- TOC entry 5378 (class 1259 OID 27503)
-- Name: idx_backup_estado_compra_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_estado_compra_fecha ON vanabby.backup_estado_compra USING btree (fecha_respaldo);


--
-- TOC entry 5381 (class 1259 OID 27504)
-- Name: idx_backup_estado_pedido_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_estado_pedido_fecha ON vanabby.backup_estado_pedido USING btree (fecha_respaldo);


--
-- TOC entry 5384 (class 1259 OID 27505)
-- Name: idx_backup_estado_venta_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_estado_venta_fecha ON vanabby.backup_estado_venta USING btree (fecha_respaldo);


--
-- TOC entry 5318 (class 1259 OID 27483)
-- Name: idx_backup_ingrediente_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_ingrediente_fecha ON vanabby.backup_ingrediente USING btree (fecha_respaldo);


--
-- TOC entry 5324 (class 1259 OID 27485)
-- Name: idx_backup_inventario_producto_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_inventario_producto_fecha ON vanabby.backup_inventario_producto USING btree (fecha_respaldo);


--
-- TOC entry 5327 (class 1259 OID 27486)
-- Name: idx_backup_lote_inventario_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_lote_inventario_fecha ON vanabby.backup_lote_inventario USING btree (fecha_respaldo);


--
-- TOC entry 5387 (class 1259 OID 27506)
-- Name: idx_backup_metodo_pago_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_metodo_pago_fecha ON vanabby.backup_metodo_pago USING btree (fecha_respaldo);


--
-- TOC entry 5348 (class 1259 OID 27493)
-- Name: idx_backup_pago_venta_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_pago_venta_fecha ON vanabby.backup_pago_venta USING btree (fecha_respaldo);


--
-- TOC entry 5390 (class 1259 OID 27507)
-- Name: idx_backup_paso_receta_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_paso_receta_fecha ON vanabby.backup_paso_receta USING btree (fecha_respaldo);


--
-- TOC entry 5336 (class 1259 OID 27489)
-- Name: idx_backup_pedido_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_pedido_fecha ON vanabby.backup_pedido USING btree (fecha_respaldo);


--
-- TOC entry 5393 (class 1259 OID 27508)
-- Name: idx_backup_permiso_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_permiso_fecha ON vanabby.backup_permiso USING btree (fecha_respaldo);


--
-- TOC entry 5396 (class 1259 OID 27509)
-- Name: idx_backup_prioridad_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_prioridad_fecha ON vanabby.backup_prioridad USING btree (fecha_respaldo);


--
-- TOC entry 5321 (class 1259 OID 27484)
-- Name: idx_backup_producto_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_producto_fecha ON vanabby.backup_producto USING btree (fecha_respaldo);


--
-- TOC entry 5315 (class 1259 OID 27482)
-- Name: idx_backup_proveedor_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_proveedor_fecha ON vanabby.backup_proveedor USING btree (fecha_respaldo);


--
-- TOC entry 5399 (class 1259 OID 27510)
-- Name: idx_backup_receta_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_receta_fecha ON vanabby.backup_receta USING btree (fecha_respaldo);


--
-- TOC entry 5402 (class 1259 OID 27511)
-- Name: idx_backup_receta_ingrediente_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_receta_ingrediente_fecha ON vanabby.backup_receta_ingrediente USING btree (fecha_respaldo);


--
-- TOC entry 5405 (class 1259 OID 27512)
-- Name: idx_backup_rol_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_rol_fecha ON vanabby.backup_rol USING btree (fecha_respaldo);


--
-- TOC entry 5408 (class 1259 OID 27513)
-- Name: idx_backup_rol_permiso_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_rol_permiso_fecha ON vanabby.backup_rol_permiso USING btree (fecha_respaldo);


--
-- TOC entry 5411 (class 1259 OID 27514)
-- Name: idx_backup_unidad_medida_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_unidad_medida_fecha ON vanabby.backup_unidad_medida USING btree (fecha_respaldo);


--
-- TOC entry 5339 (class 1259 OID 27490)
-- Name: idx_backup_venta_fecha; Type: INDEX; Schema: vanabby; Owner: postgres
--

CREATE INDEX idx_backup_venta_fecha ON vanabby.backup_venta USING btree (fecha_respaldo);


--
-- TOC entry 5476 (class 2620 OID 27965)
-- Name: anticipo trg_auditoria_financiera_anticipo; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_financiera_anticipo AFTER INSERT OR DELETE OR UPDATE ON vanabby.anticipo FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_financiera();


--
-- TOC entry 5485 (class 2620 OID 27960)
-- Name: compra trg_auditoria_financiera_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_financiera_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_financiera();


--
-- TOC entry 5488 (class 2620 OID 27961)
-- Name: detalle_compra trg_auditoria_financiera_detalle_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_financiera_detalle_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.detalle_compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_financiera();


--
-- TOC entry 5491 (class 2620 OID 27963)
-- Name: detalle_venta trg_auditoria_financiera_detalle_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_financiera_detalle_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.detalle_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_financiera();


--
-- TOC entry 5522 (class 2620 OID 27964)
-- Name: pago_venta trg_auditoria_financiera_pago_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_financiera_pago_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.pago_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_financiera();


--
-- TOC entry 5547 (class 2620 OID 27962)
-- Name: venta trg_auditoria_financiera_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_financiera_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_financiera();


--
-- TOC entry 5474 (class 2620 OID 27925)
-- Name: agenda trg_auditoria_general_agenda; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_agenda AFTER INSERT OR DELETE OR UPDATE ON vanabby.agenda FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5477 (class 2620 OID 27926)
-- Name: anticipo trg_auditoria_general_anticipo; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_anticipo AFTER INSERT OR DELETE OR UPDATE ON vanabby.anticipo FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5479 (class 2620 OID 27927)
-- Name: bloqueo trg_auditoria_general_bloqueo; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_bloqueo AFTER INSERT OR DELETE OR UPDATE ON vanabby.bloqueo FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5481 (class 2620 OID 27928)
-- Name: categoria trg_auditoria_general_categoria; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_categoria AFTER INSERT OR DELETE OR UPDATE ON vanabby.categoria FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5483 (class 2620 OID 27929)
-- Name: cliente trg_auditoria_general_cliente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_cliente AFTER INSERT OR DELETE OR UPDATE ON vanabby.cliente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5486 (class 2620 OID 27930)
-- Name: compra trg_auditoria_general_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5489 (class 2620 OID 27931)
-- Name: detalle_compra trg_auditoria_general_detalle_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_detalle_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.detalle_compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5492 (class 2620 OID 27932)
-- Name: detalle_venta trg_auditoria_general_detalle_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_detalle_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.detalle_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5494 (class 2620 OID 27933)
-- Name: direccion_cliente trg_auditoria_general_direccion_cliente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_direccion_cliente AFTER INSERT OR DELETE OR UPDATE ON vanabby.direccion_cliente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5496 (class 2620 OID 27934)
-- Name: direccion_empleado trg_auditoria_general_direccion_empleado; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_direccion_empleado AFTER INSERT OR DELETE OR UPDATE ON vanabby.direccion_empleado FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5498 (class 2620 OID 27935)
-- Name: direccion_proveedor trg_auditoria_general_direccion_proveedor; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_direccion_proveedor AFTER INSERT OR DELETE OR UPDATE ON vanabby.direccion_proveedor FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5500 (class 2620 OID 27936)
-- Name: empleado trg_auditoria_general_empleado; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_empleado AFTER INSERT OR DELETE OR UPDATE ON vanabby.empleado FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5502 (class 2620 OID 27937)
-- Name: envio trg_auditoria_general_envio; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_envio AFTER INSERT OR DELETE OR UPDATE ON vanabby.envio FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5504 (class 2620 OID 27938)
-- Name: estado_agenda trg_auditoria_general_estado_agenda; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_estado_agenda AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_agenda FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5506 (class 2620 OID 27939)
-- Name: estado_anticipo trg_auditoria_general_estado_anticipo; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_estado_anticipo AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_anticipo FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5508 (class 2620 OID 27940)
-- Name: estado_compra trg_auditoria_general_estado_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_estado_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5510 (class 2620 OID 27941)
-- Name: estado_pedido trg_auditoria_general_estado_pedido; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_estado_pedido AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_pedido FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5512 (class 2620 OID 27942)
-- Name: estado_venta trg_auditoria_general_estado_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_estado_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5514 (class 2620 OID 27943)
-- Name: ingrediente trg_auditoria_general_ingrediente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_ingrediente AFTER INSERT OR DELETE OR UPDATE ON vanabby.ingrediente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5516 (class 2620 OID 27944)
-- Name: inventario_producto trg_auditoria_general_inventario_producto; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_inventario_producto AFTER INSERT OR DELETE OR UPDATE ON vanabby.inventario_producto FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5518 (class 2620 OID 27945)
-- Name: lote_inventario trg_auditoria_general_lote_inventario; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_lote_inventario AFTER INSERT OR DELETE OR UPDATE ON vanabby.lote_inventario FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5520 (class 2620 OID 27946)
-- Name: metodo_pago trg_auditoria_general_metodo_pago; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_metodo_pago AFTER INSERT OR DELETE OR UPDATE ON vanabby.metodo_pago FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5523 (class 2620 OID 27947)
-- Name: pago_venta trg_auditoria_general_pago_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_pago_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.pago_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5525 (class 2620 OID 27948)
-- Name: paso_receta trg_auditoria_general_paso_receta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_paso_receta AFTER INSERT OR DELETE OR UPDATE ON vanabby.paso_receta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5527 (class 2620 OID 27949)
-- Name: pedido trg_auditoria_general_pedido; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_pedido AFTER INSERT OR DELETE OR UPDATE ON vanabby.pedido FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5529 (class 2620 OID 27950)
-- Name: permiso trg_auditoria_general_permiso; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_permiso AFTER INSERT OR DELETE OR UPDATE ON vanabby.permiso FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5531 (class 2620 OID 27951)
-- Name: prioridad trg_auditoria_general_prioridad; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_prioridad AFTER INSERT OR DELETE OR UPDATE ON vanabby.prioridad FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5533 (class 2620 OID 27952)
-- Name: producto trg_auditoria_general_producto; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_producto AFTER INSERT OR DELETE OR UPDATE ON vanabby.producto FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5535 (class 2620 OID 27953)
-- Name: proveedor trg_auditoria_general_proveedor; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_proveedor AFTER INSERT OR DELETE OR UPDATE ON vanabby.proveedor FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5537 (class 2620 OID 27954)
-- Name: receta trg_auditoria_general_receta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_receta AFTER INSERT OR DELETE OR UPDATE ON vanabby.receta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5539 (class 2620 OID 27955)
-- Name: receta_ingrediente trg_auditoria_general_receta_ingrediente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_receta_ingrediente AFTER INSERT OR DELETE OR UPDATE ON vanabby.receta_ingrediente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5541 (class 2620 OID 27956)
-- Name: rol trg_auditoria_general_rol; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_rol AFTER INSERT OR DELETE OR UPDATE ON vanabby.rol FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5543 (class 2620 OID 27957)
-- Name: rol_permiso trg_auditoria_general_rol_permiso; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_rol_permiso AFTER INSERT OR DELETE OR UPDATE ON vanabby.rol_permiso FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5545 (class 2620 OID 27958)
-- Name: unidad_medida trg_auditoria_general_unidad_medida; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_unidad_medida AFTER INSERT OR DELETE OR UPDATE ON vanabby.unidad_medida FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5548 (class 2620 OID 27959)
-- Name: venta trg_auditoria_general_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_auditoria_general_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_auditoria_general();


--
-- TOC entry 5475 (class 2620 OID 27907)
-- Name: agenda trg_backup_agenda; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_agenda AFTER INSERT OR DELETE OR UPDATE ON vanabby.agenda FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5478 (class 2620 OID 27902)
-- Name: anticipo trg_backup_anticipo; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_anticipo AFTER INSERT OR DELETE OR UPDATE ON vanabby.anticipo FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5551 (class 2620 OID 27967)
-- Name: auditoria_financiera trg_backup_auditoria_financiera; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_auditoria_financiera AFTER INSERT ON vanabby.auditoria_financiera FOR EACH ROW EXECUTE FUNCTION vanabby.fn_respaldar_auditorias();


--
-- TOC entry 5550 (class 2620 OID 27966)
-- Name: auditoria_general trg_backup_auditoria_general; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_auditoria_general AFTER INSERT ON vanabby.auditoria_general FOR EACH ROW EXECUTE FUNCTION vanabby.fn_respaldar_auditorias();


--
-- TOC entry 5480 (class 2620 OID 27908)
-- Name: bloqueo trg_backup_bloqueo; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_bloqueo AFTER INSERT OR DELETE OR UPDATE ON vanabby.bloqueo FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5482 (class 2620 OID 27909)
-- Name: categoria trg_backup_categoria; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_categoria AFTER INSERT OR DELETE OR UPDATE ON vanabby.categoria FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5484 (class 2620 OID 27890)
-- Name: cliente trg_backup_cliente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_cliente AFTER INSERT OR DELETE OR UPDATE ON vanabby.cliente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5487 (class 2620 OID 27897)
-- Name: compra trg_backup_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5490 (class 2620 OID 27898)
-- Name: detalle_compra trg_backup_detalle_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_detalle_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.detalle_compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5493 (class 2620 OID 27901)
-- Name: detalle_venta trg_backup_detalle_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_detalle_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.detalle_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5495 (class 2620 OID 27905)
-- Name: direccion_cliente trg_backup_direccion_cliente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_direccion_cliente AFTER INSERT OR DELETE OR UPDATE ON vanabby.direccion_cliente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5497 (class 2620 OID 27910)
-- Name: direccion_empleado trg_backup_direccion_empleado; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_direccion_empleado AFTER INSERT OR DELETE OR UPDATE ON vanabby.direccion_empleado FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5499 (class 2620 OID 27906)
-- Name: direccion_proveedor trg_backup_direccion_proveedor; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_direccion_proveedor AFTER INSERT OR DELETE OR UPDATE ON vanabby.direccion_proveedor FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5501 (class 2620 OID 27891)
-- Name: empleado trg_backup_empleado; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_empleado AFTER INSERT OR DELETE OR UPDATE ON vanabby.empleado FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5503 (class 2620 OID 27904)
-- Name: envio trg_backup_envio; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_envio AFTER INSERT OR DELETE OR UPDATE ON vanabby.envio FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5505 (class 2620 OID 27911)
-- Name: estado_agenda trg_backup_estado_agenda; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_estado_agenda AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_agenda FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5507 (class 2620 OID 27912)
-- Name: estado_anticipo trg_backup_estado_anticipo; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_estado_anticipo AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_anticipo FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5509 (class 2620 OID 27913)
-- Name: estado_compra trg_backup_estado_compra; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_estado_compra AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_compra FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5511 (class 2620 OID 27914)
-- Name: estado_pedido trg_backup_estado_pedido; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_estado_pedido AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_pedido FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5513 (class 2620 OID 27915)
-- Name: estado_venta trg_backup_estado_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_estado_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.estado_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5515 (class 2620 OID 27893)
-- Name: ingrediente trg_backup_ingrediente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_ingrediente AFTER INSERT OR DELETE OR UPDATE ON vanabby.ingrediente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5517 (class 2620 OID 27895)
-- Name: inventario_producto trg_backup_inventario_producto; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_inventario_producto AFTER INSERT OR DELETE OR UPDATE ON vanabby.inventario_producto FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5519 (class 2620 OID 27896)
-- Name: lote_inventario trg_backup_lote_inventario; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_lote_inventario AFTER INSERT OR DELETE OR UPDATE ON vanabby.lote_inventario FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5521 (class 2620 OID 27916)
-- Name: metodo_pago trg_backup_metodo_pago; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_metodo_pago AFTER INSERT OR DELETE OR UPDATE ON vanabby.metodo_pago FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5524 (class 2620 OID 27903)
-- Name: pago_venta trg_backup_pago_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_pago_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.pago_venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5526 (class 2620 OID 27917)
-- Name: paso_receta trg_backup_paso_receta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_paso_receta AFTER INSERT OR DELETE OR UPDATE ON vanabby.paso_receta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5528 (class 2620 OID 27899)
-- Name: pedido trg_backup_pedido; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_pedido AFTER INSERT OR DELETE OR UPDATE ON vanabby.pedido FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5530 (class 2620 OID 27918)
-- Name: permiso trg_backup_permiso; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_permiso AFTER INSERT OR DELETE OR UPDATE ON vanabby.permiso FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5532 (class 2620 OID 27919)
-- Name: prioridad trg_backup_prioridad; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_prioridad AFTER INSERT OR DELETE OR UPDATE ON vanabby.prioridad FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5534 (class 2620 OID 27894)
-- Name: producto trg_backup_producto; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_producto AFTER INSERT OR DELETE OR UPDATE ON vanabby.producto FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5536 (class 2620 OID 27892)
-- Name: proveedor trg_backup_proveedor; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_proveedor AFTER INSERT OR DELETE OR UPDATE ON vanabby.proveedor FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5538 (class 2620 OID 27920)
-- Name: receta trg_backup_receta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_receta AFTER INSERT OR DELETE OR UPDATE ON vanabby.receta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5540 (class 2620 OID 27921)
-- Name: receta_ingrediente trg_backup_receta_ingrediente; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_receta_ingrediente AFTER INSERT OR DELETE OR UPDATE ON vanabby.receta_ingrediente FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5542 (class 2620 OID 27922)
-- Name: rol trg_backup_rol; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_rol AFTER INSERT OR DELETE OR UPDATE ON vanabby.rol FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5544 (class 2620 OID 27923)
-- Name: rol_permiso trg_backup_rol_permiso; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_rol_permiso AFTER INSERT OR DELETE OR UPDATE ON vanabby.rol_permiso FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5546 (class 2620 OID 27924)
-- Name: unidad_medida trg_backup_unidad_medida; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_unidad_medida AFTER INSERT OR DELETE OR UPDATE ON vanabby.unidad_medida FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5549 (class 2620 OID 27900)
-- Name: venta trg_backup_venta; Type: TRIGGER; Schema: vanabby; Owner: postgres
--

CREATE TRIGGER trg_backup_venta AFTER INSERT OR DELETE OR UPDATE ON vanabby.venta FOR EACH ROW EXECUTE FUNCTION vanabby.fn_registrar_respaldo();


--
-- TOC entry 5428 (class 2606 OID 26899)
-- Name: agenda agenda_estado_agenda_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.agenda
    ADD CONSTRAINT agenda_estado_agenda_id_fkey FOREIGN KEY (estado_agenda_id) REFERENCES vanabby.estado_agenda(estado_agenda_id);


--
-- TOC entry 5429 (class 2606 OID 26904)
-- Name: agenda agenda_responsable_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.agenda
    ADD CONSTRAINT agenda_responsable_empleado_id_fkey FOREIGN KEY (responsable_empleado_id) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5430 (class 2606 OID 26909)
-- Name: agenda agenda_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.agenda
    ADD CONSTRAINT agenda_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES vanabby.venta(venta_id);


--
-- TOC entry 5431 (class 2606 OID 26914)
-- Name: anticipo anticipo_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.anticipo
    ADD CONSTRAINT anticipo_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES vanabby.cliente(cliente_id);


--
-- TOC entry 5432 (class 2606 OID 26919)
-- Name: anticipo anticipo_estado_anticipo_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.anticipo
    ADD CONSTRAINT anticipo_estado_anticipo_id_fkey FOREIGN KEY (estado_anticipo_id) REFERENCES vanabby.estado_anticipo(estado_anticipo_id);


--
-- TOC entry 5433 (class 2606 OID 26924)
-- Name: anticipo anticipo_metodo_pago_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.anticipo
    ADD CONSTRAINT anticipo_metodo_pago_id_fkey FOREIGN KEY (metodo_pago_id) REFERENCES vanabby.metodo_pago(metodo_pago_id);


--
-- TOC entry 5434 (class 2606 OID 26929)
-- Name: anticipo anticipo_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.anticipo
    ADD CONSTRAINT anticipo_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES vanabby.venta(venta_id);


--
-- TOC entry 5435 (class 2606 OID 26934)
-- Name: bloqueo bloqueo_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.bloqueo
    ADD CONSTRAINT bloqueo_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES vanabby.cliente(cliente_id);


--
-- TOC entry 5436 (class 2606 OID 26939)
-- Name: bloqueo bloqueo_desbloqueado_por_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.bloqueo
    ADD CONSTRAINT bloqueo_desbloqueado_por_empleado_id_fkey FOREIGN KEY (desbloqueado_por_empleado_id) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5437 (class 2606 OID 26944)
-- Name: bloqueo bloqueo_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.bloqueo
    ADD CONSTRAINT bloqueo_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5438 (class 2606 OID 26949)
-- Name: compra compra_estado_compra_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.compra
    ADD CONSTRAINT compra_estado_compra_id_fkey FOREIGN KEY (estado_compra_id) REFERENCES vanabby.estado_compra(estado_compra_id);


--
-- TOC entry 5439 (class 2606 OID 26954)
-- Name: compra compra_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.compra
    ADD CONSTRAINT compra_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES vanabby.proveedor(proveedor_id);


--
-- TOC entry 5440 (class 2606 OID 26959)
-- Name: detalle_compra detalle_compra_compra_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.detalle_compra
    ADD CONSTRAINT detalle_compra_compra_id_fkey FOREIGN KEY (compra_id) REFERENCES vanabby.compra(compra_id);


--
-- TOC entry 5441 (class 2606 OID 26964)
-- Name: detalle_compra detalle_compra_ingrediente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.detalle_compra
    ADD CONSTRAINT detalle_compra_ingrediente_id_fkey FOREIGN KEY (ingrediente_id) REFERENCES vanabby.ingrediente(ingrediente_id);


--
-- TOC entry 5442 (class 2606 OID 26969)
-- Name: detalle_venta detalle_venta_producto_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.detalle_venta
    ADD CONSTRAINT detalle_venta_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES vanabby.producto(producto_id);


--
-- TOC entry 5443 (class 2606 OID 26974)
-- Name: detalle_venta detalle_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.detalle_venta
    ADD CONSTRAINT detalle_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES vanabby.venta(venta_id);


--
-- TOC entry 5444 (class 2606 OID 26979)
-- Name: direccion_cliente direccion_cliente_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.direccion_cliente
    ADD CONSTRAINT direccion_cliente_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES vanabby.cliente(cliente_id);


--
-- TOC entry 5445 (class 2606 OID 26984)
-- Name: direccion_empleado direccion_empleado_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.direccion_empleado
    ADD CONSTRAINT direccion_empleado_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5446 (class 2606 OID 26989)
-- Name: direccion_proveedor direccion_proveedor_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.direccion_proveedor
    ADD CONSTRAINT direccion_proveedor_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES vanabby.proveedor(proveedor_id);


--
-- TOC entry 5447 (class 2606 OID 26994)
-- Name: empleado empleado_rol_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.empleado
    ADD CONSTRAINT empleado_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES vanabby.rol(rol_id);


--
-- TOC entry 5448 (class 2606 OID 26999)
-- Name: envio envio_direccion_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.envio
    ADD CONSTRAINT envio_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES vanabby.direccion_cliente(direccion_id);


--
-- TOC entry 5449 (class 2606 OID 27004)
-- Name: envio envio_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.envio
    ADD CONSTRAINT envio_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5450 (class 2606 OID 27009)
-- Name: envio envio_pedido_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.envio
    ADD CONSTRAINT envio_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES vanabby.pedido(pedido_id);


--
-- TOC entry 5451 (class 2606 OID 27014)
-- Name: ingrediente ingrediente_unidad_medida_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.ingrediente
    ADD CONSTRAINT ingrediente_unidad_medida_id_fkey FOREIGN KEY (unidad_medida_id) REFERENCES vanabby.unidad_medida(unidad_medida_id);


--
-- TOC entry 5452 (class 2606 OID 27019)
-- Name: inventario_producto inventario_producto_producto_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.inventario_producto
    ADD CONSTRAINT inventario_producto_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES vanabby.producto(producto_id);


--
-- TOC entry 5453 (class 2606 OID 27024)
-- Name: lote_inventario lote_inventario_ingrediente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.lote_inventario
    ADD CONSTRAINT lote_inventario_ingrediente_id_fkey FOREIGN KEY (ingrediente_id) REFERENCES vanabby.ingrediente(ingrediente_id);


--
-- TOC entry 5454 (class 2606 OID 27029)
-- Name: lote_inventario lote_inventario_unidad_medida_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.lote_inventario
    ADD CONSTRAINT lote_inventario_unidad_medida_id_fkey FOREIGN KEY (unidad_medida_id) REFERENCES vanabby.unidad_medida(unidad_medida_id);


--
-- TOC entry 5455 (class 2606 OID 27034)
-- Name: pago_venta pago_venta_metodo_pago_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pago_venta
    ADD CONSTRAINT pago_venta_metodo_pago_id_fkey FOREIGN KEY (metodo_pago_id) REFERENCES vanabby.metodo_pago(metodo_pago_id);


--
-- TOC entry 5456 (class 2606 OID 27039)
-- Name: pago_venta pago_venta_registrado_por_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pago_venta
    ADD CONSTRAINT pago_venta_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5457 (class 2606 OID 27044)
-- Name: pago_venta pago_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pago_venta
    ADD CONSTRAINT pago_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES vanabby.venta(venta_id);


--
-- TOC entry 5458 (class 2606 OID 27049)
-- Name: paso_receta paso_receta_receta_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.paso_receta
    ADD CONSTRAINT paso_receta_receta_id_fkey FOREIGN KEY (receta_id) REFERENCES vanabby.receta(receta_id);


--
-- TOC entry 5459 (class 2606 OID 27054)
-- Name: pedido pedido_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pedido
    ADD CONSTRAINT pedido_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES vanabby.cliente(cliente_id);


--
-- TOC entry 5460 (class 2606 OID 27059)
-- Name: pedido pedido_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pedido
    ADD CONSTRAINT pedido_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5461 (class 2606 OID 27064)
-- Name: pedido pedido_estado_pedido_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pedido
    ADD CONSTRAINT pedido_estado_pedido_id_fkey FOREIGN KEY (estado_pedido_id) REFERENCES vanabby.estado_pedido(estado_pedido_id);


--
-- TOC entry 5462 (class 2606 OID 27069)
-- Name: pedido pedido_prioridad_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.pedido
    ADD CONSTRAINT pedido_prioridad_id_fkey FOREIGN KEY (prioridad_id) REFERENCES vanabby.prioridad(prioridad_id);


--
-- TOC entry 5463 (class 2606 OID 27074)
-- Name: producto producto_categoria_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.producto
    ADD CONSTRAINT producto_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES vanabby.categoria(categoria_id);


--
-- TOC entry 5465 (class 2606 OID 27079)
-- Name: receta_ingrediente receta_ingrediente_ingrediente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.receta_ingrediente
    ADD CONSTRAINT receta_ingrediente_ingrediente_id_fkey FOREIGN KEY (ingrediente_id) REFERENCES vanabby.ingrediente(ingrediente_id);


--
-- TOC entry 5466 (class 2606 OID 27084)
-- Name: receta_ingrediente receta_ingrediente_receta_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.receta_ingrediente
    ADD CONSTRAINT receta_ingrediente_receta_id_fkey FOREIGN KEY (receta_id) REFERENCES vanabby.receta(receta_id);


--
-- TOC entry 5464 (class 2606 OID 27089)
-- Name: receta receta_producto_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.receta
    ADD CONSTRAINT receta_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES vanabby.producto(producto_id);


--
-- TOC entry 5467 (class 2606 OID 27094)
-- Name: rol_permiso rol_permiso_permiso_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.rol_permiso
    ADD CONSTRAINT rol_permiso_permiso_id_fkey FOREIGN KEY (permiso_id) REFERENCES vanabby.permiso(permiso_id);


--
-- TOC entry 5468 (class 2606 OID 27099)
-- Name: rol_permiso rol_permiso_rol_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.rol_permiso
    ADD CONSTRAINT rol_permiso_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES vanabby.rol(rol_id);


--
-- TOC entry 5469 (class 2606 OID 27104)
-- Name: venta venta_cliente_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.venta
    ADD CONSTRAINT venta_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES vanabby.cliente(cliente_id);


--
-- TOC entry 5470 (class 2606 OID 27109)
-- Name: venta venta_empleado_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.venta
    ADD CONSTRAINT venta_empleado_id_fkey FOREIGN KEY (empleado_id) REFERENCES vanabby.empleado(empleado_id);


--
-- TOC entry 5471 (class 2606 OID 27114)
-- Name: venta venta_estado_venta_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.venta
    ADD CONSTRAINT venta_estado_venta_id_fkey FOREIGN KEY (estado_venta_id) REFERENCES vanabby.estado_venta(estado_venta_id);


--
-- TOC entry 5472 (class 2606 OID 27119)
-- Name: venta venta_metodo_pago_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.venta
    ADD CONSTRAINT venta_metodo_pago_id_fkey FOREIGN KEY (metodo_pago_id) REFERENCES vanabby.metodo_pago(metodo_pago_id);


--
-- TOC entry 5473 (class 2606 OID 27124)
-- Name: venta venta_pedido_id_fkey; Type: FK CONSTRAINT; Schema: vanabby; Owner: postgres
--

ALTER TABLE ONLY vanabby.venta
    ADD CONSTRAINT venta_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES vanabby.pedido(pedido_id);


-- Completed on 2026-11-25 07:52:47

--
-- PostgreSQL database dump complete
--

\unrestrict WzZLLFrEZBNickKMdrfXkESXiOcOJg3YV6iHlbcO04qzDpbsZgEZ6IP6l1Qqqit

