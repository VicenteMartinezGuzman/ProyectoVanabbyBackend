/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

/**
 *
 * @author vicen
 */
public class Compra {

    private int compraId;
    private Integer proveedorId;    // FK -> proveedor
    private Timestamp creadoEn;
    private Date fechaEsperada;
    private Integer estadoCompraId; // FK -> estado_compra
    private List<DetalleCompra> detalles; // Relación 1:N

    public Compra() {
    }

    public int getCompraId() {
        return compraId;
    }

    public void setCompraId(int compraId) {
        this.compraId = compraId;
    }

    public Integer getProveedorId() {
        return proveedorId;
    }

    public void setProveedorId(Integer proveedorId) {
        this.proveedorId = proveedorId;
    }

    public Timestamp getCreadoEn() {
        return creadoEn;
    }

    public void setCreadoEn(Timestamp creadoEn) {
        this.creadoEn = creadoEn;
    }

    public Date getFechaEsperada() {
        return fechaEsperada;
    }

    public void setFechaEsperada(Date fechaEsperada) {
        this.fechaEsperada = fechaEsperada;
    }

    public Integer getEstadoCompraId() {
        return estadoCompraId;
    }

    public void setEstadoCompraId(Integer estadoCompraId) {
        this.estadoCompraId = estadoCompraId;
    }

    public List<DetalleCompra> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<DetalleCompra> detalles) {
        this.detalles = detalles;
    }
}
