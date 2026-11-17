/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

import java.sql.Timestamp;

/**
 *
 * @author vicen
 */
public class Empleado {
    private int empleado_id;
    private String nombre_usuario;
    private String clave_hash;
    private String nombre;
    private String ap_paterno;
    private String ap_materno;
    private int rol_id;//puede tener muchos roles?
    private int bloqueado;//porque es un numero, a que se refiere bloqueado?
    private int intentos_fallidos;
    private Timestamp ultimo_intento;
    private Timestamp creado_en;

    public Empleado(int empleado_id, String nombre_usuario, String clave_hash, String nombre, String ap_paterno, String ap_materno, int rol_id, int bloqueado, int intentos_fallidos, Timestamp ultimo_intento, Timestamp creado_en) {
        this.empleado_id = empleado_id;
        this.nombre_usuario = nombre_usuario;
        this.clave_hash = clave_hash;
        this.nombre = nombre;
        this.ap_paterno = ap_paterno;
        this.ap_materno = ap_materno;
        this.rol_id = rol_id;
        this.bloqueado = bloqueado;
        this.intentos_fallidos = intentos_fallidos;
        this.ultimo_intento = ultimo_intento;
        this.creado_en = creado_en;
    }

    public int getEmpleado_id() {
        return empleado_id;
    }

    public void setEmpleado_id(int empleado_id) {
        this.empleado_id = empleado_id;
    }

    public String getNombre_usuario() {
        return nombre_usuario;
    }

    public void setNombre_usuario(String nombre_usuario) {
        this.nombre_usuario = nombre_usuario;
    }

    public String getClave_hash() {
        return clave_hash;
    }

    public void setClave_hash(String clave_hash) {
        this.clave_hash = clave_hash;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getAp_paterno() {
        return ap_paterno;
    }

    public void setAp_paterno(String ap_paterno) {
        this.ap_paterno = ap_paterno;
    }

    public String getAp_materno() {
        return ap_materno;
    }

    public void setAp_materno(String ap_materno) {
        this.ap_materno = ap_materno;
    }

    public int getRol_id() {
        return rol_id;
    }

    public void setRol_id(int rol_id) {
        this.rol_id = rol_id;
    }

    public int getBloqueado() {
        return bloqueado;
    }

    public void setBloqueado(int bloqueado) {
        this.bloqueado = bloqueado;
    }

    public int getIntentos_fallidos() {
        return intentos_fallidos;
    }

    public void setIntentos_fallidos(int intentos_fallidos) {
        this.intentos_fallidos = intentos_fallidos;
    }

    public Timestamp getUltimo_intento() {
        return ultimo_intento;
    }

    public void setUltimo_intento(Timestamp ultimo_intento) {
        this.ultimo_intento = ultimo_intento;
    }

    public Timestamp getCreado_en() {
        return creado_en;
    }

    public void setCreado_en(Timestamp creado_en) {
        this.creado_en = creado_en;
    }
    
}
