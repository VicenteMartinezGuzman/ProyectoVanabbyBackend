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
public class PagoVenta {

    private int pagoVentaId;
    private Integer ventaId;       // FK -> venta
    private Integer metodoPagoId;  // FK -> metodo_pago
    private BigDecimal monto;
    private Timestamp pagadoEn;
    private Integer registradoPor; // FK -> empleado

    public PagoVenta() {
    }

    public int getPagoVentaId() {
        return pagoVentaId;
    }

    public void setPagoVentaId(int pagoVentaId) {
        this.pagoVentaId = pagoVentaId;
    }

    public Integer getVentaId() {
        return ventaId;
    }

    public void setVentaId(Integer ventaId) {
        this.ventaId = ventaId;
    }

    public Integer getMetodoPagoId() {
        return metodoPagoId;
    }

    public void setMetodoPagoId(Integer metodoPagoId) {
        this.metodoPagoId = metodoPagoId;
    }

    public BigDecimal getMonto() {
        return monto;
    }

    public void setMonto(BigDecimal monto) {
        this.monto = monto;
    }

    public Timestamp getPagadoEn() {
        return pagadoEn;
    }

    public void setPagadoEn(Timestamp pagadoEn) {
        this.pagadoEn = pagadoEn;
    }

    public Integer getRegistradoPor() {
        return registradoPor;
    }

    public void setRegistradoPor(Integer registradoPor) {
        this.registradoPor = registradoPor;
    }
}
