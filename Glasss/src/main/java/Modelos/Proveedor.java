/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

import java.util.List;

/**
 *
 * @author vicen
 */
public class Proveedor {

    private int proveedorId;
    private String nombre;
    private String contactoNombre;
    private String contactoApPaterno;
    private String contactoApMaterno;
    private String telefono;
    private String correo;
    private String notas;
    private List<DireccionProveedor> direcciones; // Relación 1:N

    public Proveedor() {
    }

    public int getProveedorId() {
        return proveedorId;
    }

    public void setProveedorId(int proveedorId) {
        this.proveedorId = proveedorId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getContactoNombre() {
        return contactoNombre;
    }

    public void setContactoNombre(String contactoNombre) {
        this.contactoNombre = contactoNombre;
    }

    public String getContactoApPaterno() {
        return contactoApPaterno;
    }

    public void setContactoApPaterno(String contactoApPaterno) {
        this.contactoApPaterno = contactoApPaterno;
    }

    public String getContactoApMaterno() {
        return contactoApMaterno;
    }

    public void setContactoApMaterno(String contactoApMaterno) {
        this.contactoApMaterno = contactoApMaterno;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }

    public List<DireccionProveedor> getDirecciones() {
        return direcciones;
    }

    public void setDirecciones(List<DireccionProveedor> direcciones) {
        this.direcciones = direcciones;
    }
}
