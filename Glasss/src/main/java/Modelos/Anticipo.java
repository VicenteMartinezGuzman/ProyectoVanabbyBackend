/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Modelos;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 *
 * @author vicen
 */
public class Anticipo {

    private int anticipoId;
    private Integer ventaId;          // FK -> venta
    private Integer clienteId;        // FK -> cliente
    private BigDecimal montoAnticipo;
    private BigDecimal montoRestante;
    private Timestamp fechaRegistro;
    private Timestamp fechaLimite;
    private Integer estadoAnticipoId; // FK -> estado_anticipo
    private Integer metodoPagoId;     // FK -> metodo_pago

    public Anticipo() {
    }

    public int getAnticipoId() {
        return anticipoId;
    }

    public void setAnticipoId(int anticipoId) {
        this.anticipoId = anticipoId;
    }

    public Integer getVentaId() {
        return ventaId;
    }

    public void setVentaId(Integer ventaId) {
        this.ventaId = ventaId;
    }

    public Integer getClienteId() {
        return clienteId;
    }

    public void setClienteId(Integer clienteId) {
        this.clienteId = clienteId;
    }

    public BigDecimal getMontoAnticipo() {
        return montoAnticipo;
    }

    public void setMontoAnticipo(BigDecimal montoAnticipo) {
        this.montoAnticipo = montoAnticipo;
    }

    public BigDecimal getMontoRestante() {
        return montoRestante;
    }

    public void setMontoRestante(BigDecimal montoRestante) {
        this.montoRestante = montoRestante;
    }

    public Timestamp getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Timestamp fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public Timestamp getFechaLimite() {
        return fechaLimite;
    }

    public void setFechaLimite(Timestamp fechaLimite) {
        this.fechaLimite = fechaLimite;
    }

    public Integer getEstadoAnticipoId() {
        return estadoAnticipoId;
    }

    public void setEstadoAnticipoId(Integer estadoAnticipoId) {
        this.estadoAnticipoId = estadoAnticipoId;
    }

    public Integer getMetodoPagoId() {
        return metodoPagoId;
    }

    public void setMetodoPagoId(Integer metodoPagoId) {
        this.metodoPagoId = metodoPagoId;
    }
}
