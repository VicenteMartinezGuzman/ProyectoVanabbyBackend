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
import java.sql.Timestamp;
import java.util.List;

public class Empleado {

    private int empleadoId;
    private String nombreUsuario;
    private String claveHash;
    private String nombre;
    private String apPaterno;
    private String apMaterno;
    private Integer rolId; // FK -> rol
    private Short bloqueado;
    private Integer intentosFallidos;
    private Timestamp ultimoIntento;
    private Timestamp creadoEn;
    private List<DireccionEmpleado> direcciones; // Relación 1:N

    public Empleado() {
    }

    public int getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(int empleadoId) {
        this.empleadoId = empleadoId;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public String getClaveHash() {
        return claveHash;
    }

    public void setClaveHash(String claveHash) {
        this.claveHash = claveHash;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApPaterno() {
        return apPaterno;
    }

    public void setApPaterno(String apPaterno) {
        this.apPaterno = apPaterno;
    }

    public String getApMaterno() {
        return apMaterno;
    }

    public void setApMaterno(String apMaterno) {
        this.apMaterno = apMaterno;
    }

    public Integer getRolId() {
        return rolId;
    }

    public void setRolId(Integer rolId) {
        this.rolId = rolId;
    }

    public Short getBloqueado() {
        return bloqueado;
    }

    public void setBloqueado(Short bloqueado) {
        this.bloqueado = bloqueado;
    }

    public Integer getIntentosFallidos() {
        return intentosFallidos;
    }

    public void setIntentosFallidos(Integer intentosFallidos) {
        this.intentosFallidos = intentosFallidos;
    }

    public Timestamp getUltimoIntento() {
        return ultimoIntento;
    }

    public void setUltimoIntento(Timestamp ultimoIntento) {
        this.ultimoIntento = ultimoIntento;
    }

    public Timestamp getCreadoEn() {
        return creadoEn;
    }

    public void setCreadoEn(Timestamp creadoEn) {
        this.creadoEn = creadoEn;
    }

    public List<DireccionEmpleado> getDirecciones() {
        return direcciones;
    }

    public void setDirecciones(List<DireccionEmpleado> direcciones) {
        this.direcciones = direcciones;
    }
}
