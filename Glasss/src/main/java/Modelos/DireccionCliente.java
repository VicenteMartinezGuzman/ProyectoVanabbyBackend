/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

/**
 *
 * @author vicen
 */
public class DireccionCliente {

    private int direccionId;
    private int clienteId; // FK -> cliente
    private String alias;
    private String calle;
    private String numero;
    private String colonia;
    private String ciudad;
    private String estadoGeo;
    private String cp;
    private Short esPrincipal;

    public DireccionCliente() {
    }

    public int getDireccionId() {
        return direccionId;
    }

    public void setDireccionId(int direccionId) {
        this.direccionId = direccionId;
    }

    public int getClienteId() {
        return clienteId;
    }

    public void setClienteId(int clienteId) {
        this.clienteId = clienteId;
    }

    public String getAlias() {
        return alias;
    }

    public void setAlias(String alias) {
        this.alias = alias;
    }

    public String getCalle() {
        return calle;
    }

    public void setCalle(String calle) {
        this.calle = calle;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public String getColonia() {
        return colonia;
    }

    public void setColonia(String colonia) {
        this.colonia = colonia;
    }

    public String getCiudad() {
        return ciudad;
    }

    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
    }

    public String getEstadoGeo() {
        return estadoGeo;
    }

    public void setEstadoGeo(String estadoGeo) {
        this.estadoGeo = estadoGeo;
    }

    public String getCp() {
        return cp;
    }

    public void setCp(String cp) {
        this.cp = cp;
    }

    public Short getEsPrincipal() {
        return esPrincipal;
    }

    public void setEsPrincipal(Short esPrincipal) {
        this.esPrincipal = esPrincipal;
    }
}
